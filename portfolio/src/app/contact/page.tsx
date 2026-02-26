// contact/page.tsx — Contact

import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Contact — James Dishman',
}

export default function ContactPage() {
  return (
    <div className="container-md py-20">

      <p className="section-label mb-4">Let&apos;s Talk</p>
      <h1 className="text-3xl md:text-4xl font-semibold text-white mb-4">Contact</h1>
      <p className="text-zinc-400 mb-16 max-w-xl">
        Always open to collaboration on UX, AI, creative coding, and research projects.
        Reach out through any of the channels below.
      </p>

      <div className="grid gap-4 sm:grid-cols-2">
        {contacts.map((contact) => (
          <a
            key={contact.label}
            href={contact.href}
            target={contact.external ? '_blank' : undefined}
            rel={contact.external ? 'noopener noreferrer' : undefined}
            className="project-card flex items-center gap-4 group"
          >
            <span className="text-3xl">{contact.icon}</span>
            <div>
              <p className="text-xs text-zinc-500 uppercase tracking-wider mb-0.5">{contact.label}</p>
              <p className="text-white group-hover:text-accent transition-colors duration-150">
                {contact.display}
              </p>
            </div>
          </a>
        ))}
      </div>

    </div>
  )
}

const contacts = [
  {
    icon: '📧',
    label: 'Email',
    display: 'nomadjames@gmail.com',
    href: 'mailto:nomadjames@gmail.com',
    external: false,
  },
  {
    icon: '💼',
    label: 'LinkedIn',
    display: 'linkedin.com/in/jamesdishman',
    href: 'https://www.linkedin.com/in/jamesdishman',
    external: true,
  },
  {
    icon: '🐙',
    label: 'GitHub',
    display: 'github.com/nomadjames',
    href: 'https://github.com/nomadjames',
    external: true,
  },
  {
    icon: '🎛',
    label: 'Pittsburgh Ableton UG',
    display: 'Ableton User Groups',
    href: 'https://www.ableton.com/en/community/user-groups/',
    external: true,
  },
]
