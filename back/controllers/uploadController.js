exports.uploadImage = (req, res) => {
  if (!req.file) return res.status(400).json({ message: "No file uploaded" });

  // Assuming you use Multer to handle uploads
  const imageUrl = `/uploads/${req.file.filename}`;
  res.status(201).json({ imageUrl });
};
