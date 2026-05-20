async function sendEmail({ to, subject, text }) {
  if (!process.env.BREVO_API_KEY) {
    console.log('Email API is not configured.')
    console.log('To:', to)
    console.log('Subject:', subject)
    console.log('Text:', text)
    return
  }

  const response = await fetch('https://api.brevo.com/v3/smtp/email', {
    method: 'POST',
    headers: {
      accept: 'application/json',
      'api-key': process.env.BREVO_API_KEY,
      'content-type': 'application/json',
    },
    body: JSON.stringify({
      sender: {
        email: process.env.SMTP_FROM,
        name: 'Urban Quest',
      },
      to: [
        {
          email: to,
        },
      ],
      subject,
      textContent: text,
    }),
  })

  if (!response.ok) {
    const responseBody = await response.text()
    throw new Error(`Failed to send email: ${responseBody}`)
  }
}

module.exports = {
  sendEmail,
}
