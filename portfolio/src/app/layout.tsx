// layout.tsx — Root layout
// This wraps every page on the site with the nav bar, footer, and shared metadata.

import type { Metadata } from 'next'
import './globals.css'
import Nav from '@/components/Nav'
import Footer from '@/components/Footer'

export const metadata: Metadata = {
  title: 'James Dishman — UX Researcher & Designer',
  description:
    'James Dishman is a UX researcher, designer, and developer-in-progress pursuing an MS in User Experience at Kent State University. Co-founder of the Pittsburgh Ableton User Group.',
  keywords: ['UX', 'design', 'research', 'synthesizer', 'iOS', 'Ableton', 'AI', 'knowledge management'],
  authors: [{ name: 'James Dishman' }],
  openGraph: {
    title: 'James Dishman — UX Researcher & Designer',
    description: 'Strategist · Designer · Researcher · Developer-in-Progress',
    url: 'https://www.nomadjames.com',
    siteName: 'nomadjames.com',
    type: 'website',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className="min-h-screen flex flex-col">
        <Nav />
        <main className="flex-1">{children}</main>
        <Footer />
      </body>
    </html>
  )
}
