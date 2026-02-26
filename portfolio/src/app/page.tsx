// page.tsx — Home / Hero
// The first thing visitors see when they load nomadjames.com.

import Link from 'next/link'

export default function HomePage() {
  return (
    <div className="container-md py-24 md:py-36">

      {/* Status badge */}
      <div className="flex items-center gap-2 mb-8">
        <span className="relative flex h-2.5 w-2.5">
          <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-accent opacity-75" />
          <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-accent" />
        </span>
        <span className="section-label">Available for collaboration</span>
      </div>

      {/* Hero heading */}
      <h1 className="text-4xl md:text-6xl font-semibold tracking-tight text-white mb-6 leading-tight">
        James Dishman
      </h1>

      {/* Tagline */}
      <p className="text-xl md:text-2xl text-zinc-400 mb-4 font-light">
        Strategist · Designer · Researcher · Developer-in-Progress
      </p>

      {/* Bio */}
      <p className="text-zinc-400 leading-relaxed max-w-2xl mb-10">
        I&apos;m a{' '}
        <span className="text-white">UX researcher and designer</span>{' '}
        pursuing my{' '}
        <span className="text-white">MS in User Experience at Kent State University</span>.
        My work sits at the intersection of{' '}
        <span className="text-white">AI-enhanced creativity</span>,{' '}
        <span className="text-white">knowledge management</span>, and{' '}
        <span className="text-white">human-computer interaction</span>.
        I&apos;m also co-founder of the{' '}
        <span className="text-white">Pittsburgh Ableton User Group</span>.
      </p>

      {/* CTAs */}
      <div className="flex flex-wrap gap-4">
        <Link
          href="/projects"
          className="px-6 py-3 rounded-xl bg-accent text-black font-medium hover:bg-accent-dark transition-colors duration-150"
        >
          View Projects
        </Link>
        <Link
          href="/contact"
          className="px-6 py-3 rounded-xl border border-zinc-700 text-zinc-300 font-medium hover:border-zinc-500 hover:text-white transition-colors duration-150"
        >
          Get in Touch
        </Link>
      </div>

      {/* Divider */}
      <div className="mt-24 border-t border-zinc-800 pt-16">
        <p className="section-label mb-8">Current Focus</p>
        <div className="grid gap-4 md:grid-cols-3">
          {focus.map((item) => (
            <div key={item.title} className="p-4 rounded-xl bg-zinc-900 border border-zinc-800">
              <p className="text-2xl mb-3">{item.icon}</p>
              <p className="text-white font-medium mb-1">{item.title}</p>
              <p className="text-sm text-zinc-500">{item.description}</p>
            </div>
          ))}
        </div>
      </div>

    </div>
  )
}

const focus = [
  {
    icon: '🎹',
    title: 'iOS Synthesizer',
    description: 'Touch- and sensor-controlled sound engine connecting to Ableton Live and modular synths.',
  },
  {
    icon: '🧠',
    title: 'Focus Ecosystem',
    description: 'AI-enhanced knowledge management system with intelligent backlinking.',
  },
  {
    icon: '⚡',
    title: 'Creative Coding',
    description: 'Learning JavaScript, p5.js, and VST development — bridging design and code.',
  },
]
