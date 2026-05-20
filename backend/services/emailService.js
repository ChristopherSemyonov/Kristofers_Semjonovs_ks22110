const nodemailer = require('nodemailer')

async function sendEmail({ to, subject, text }) {
  if (
    !process.env.SMTP_HOST ||
    !process.env.SMTP_USER ||
    !process.env.SMTP_PASSWORD
  ) {
    console.log('Email sending is not configured.')
    console.log('To:', to)
    console.log('Subject:', subject)
    console.log('Text:', text)
    return
  }

  const port = Number(process.env.SMTP_PORT || 587)

  const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port,
    secure: port === 465,
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASSWORD,
    },
    connectionTimeout: 15000,
    greetingTimeout: 15000,
    socketTimeout: 15000,
  })

  await transporter.sendMail({
    from: process.env.SMTP_FROM || process.env.SMTP_USER,
    to,
    subject,
    text,
  })
}

module.exports = {
  sendEmail,
}
