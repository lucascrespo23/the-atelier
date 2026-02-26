export const config = { api: { bodyParser: false } };

export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const SUPABASE_URL = process.env.SUPABASE_URL;
  const SUPABASE_KEY = process.env.SUPABASE_SECRET_KEY;

  try {
    // Read raw body
    const chunks = [];
    for await (const chunk of req) chunks.push(chunk);
    const buffer = Buffer.concat(chunks);

    // Get filename from header
    const filename = req.headers['x-filename'] || 'file';
    const contentType = req.headers['content-type'] || 'application/octet-stream';
    
    // Generate unique path
    const timestamp = Date.now();
    const safeName = filename.replace(/[^a-zA-Z0-9._-]/g, '_');
    const path = `${timestamp}-${safeName}`;

    // Upload to Supabase Storage
    const uploadRes = await fetch(`${SUPABASE_URL}/storage/v1/object/attachments/${path}`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`,
        'Content-Type': contentType
      },
      body: buffer
    });

    if (!uploadRes.ok) {
      const err = await uploadRes.text();
      return res.status(500).json({ error: 'Upload failed', details: err });
    }

    // Return public URL
    const publicUrl = `${SUPABASE_URL}/storage/v1/object/public/attachments/${path}`;
    return res.status(200).json({ url: publicUrl, name: filename, path });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
}
