const multer = require('multer')
const path = require('path')

const storage = multer.memoryStorage()

const upload = multer({
  storage,
  limits: {
    fileSize: 2 * 1024 * 1024,
  },
  fileFilter: function (req, file, cb) {
    const allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp']
    const extension = path.extname(file.originalname).toLowerCase()

    const isImageMimeType = file.mimetype.startsWith('image/')
    const isAllowedExtension = allowedExtensions.includes(extension)

    if (!isImageMimeType && !isAllowedExtension) {
      return cb(new Error('Only image files are allowed'))
    }

    cb(null, true)
  },
})

module.exports = upload
