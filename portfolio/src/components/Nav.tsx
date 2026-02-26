// Nav.tsx — Top navigation bar

import Link from 'next/link'

export default function Nav() {
  return (
    <header className="sticky top-0 z-50 border-b border-zinc-800/80 bg-zinc-950/90 backdrop-blur-md">
      <div className="container-md py-4 flex items-center justify-between">

        {/* Logo / name */}
        <Link href="/" className="font-mono text-sm text-zinc-300 hover:text-white transition-colors">
          nomadjames
        </Link>

        {/* Nav links */}
        <nav className="flex items-center gap-6">
          <Link href="/projects" className="nav-link">Projects</Link>
          <Link href="/about"    className="nav-link">About</Link>
          <Link href="/contact"  className="nav-link">Contact</Link>
        </nav>

      </div>
    </header>
  )
}
