// projects/page.tsx — Projects overview
// Shows all three active projects as cards with status badges.

import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Projects — James Dishman',
  description: 'Active projects by James Dishman: iOS Synthesizer, Focus Ecosystem, and Symbolic Logic & Programming.',
}

export default function ProjectsPage() {
  return (
    <div className="container-md py-20">

      <p className="section-label mb-4">Work</p>
      <h1 className="text-3xl md:text-4xl font-semibold text-white mb-4">Projects</h1>
      <p className="text-zinc-400 mb-16 max-w-xl">
        All three projects are in active development. Each one explores a different
        dimension of the intersection between design, technology, and sound.
      </p>

      <div className="flex flex-col gap-6">
        {projects.map((project) => (
          <ProjectCard key={project.title} {...project} />
        ))}
      </div>

    </div>
  )
}

// MARK: - ProjectCard component

function ProjectCard({
  icon,
  title,
  status,
  statusColor,
  description,
  tech,
  githubPath,
}: Project) {
  return (
    <div className="project-card">
      <div className="flex items-start justify-between gap-4 mb-4">
        <div className="flex items-center gap-3">
          <span className="text-2xl">{icon}</span>
          <h2 className="text-xl font-semibold text-white">{title}</h2>
        </div>
        <StatusBadge label={status} color={statusColor} />
      </div>

      <p className="text-zinc-400 mb-6 leading-relaxed">{description}</p>

      {/* Tech stack pills */}
      <div className="flex flex-wrap gap-2 mb-4">
        {tech.map((t) => (
          <span
            key={t}
            className="px-3 py-1 rounded-full text-xs font-mono bg-zinc-800 text-zinc-400 border border-zinc-700"
          >
            {t}
          </span>
        ))}
      </div>

      {/* GitHub link (if available) */}
      {githubPath && (
        <a
          href={`https://github.com/nomadjames/nomadjames/tree/main/${githubPath}`}
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center gap-1.5 text-sm text-accent hover:text-accent-dark transition-colors"
        >
          View on GitHub
          <svg width="12" height="12" viewBox="0 0 12 12" fill="currentColor">
            <path d="M2.5 1h7a.5.5 0 0 1 .5.5v7a.5.5 0 0 1-1 0V2.707L2.354 9.354a.5.5 0 0 1-.708-.708L8.293 2H2.5a.5.5 0 0 1 0-1Z" />
          </svg>
        </a>
      )}
    </div>
  )
}

function StatusBadge({ label, color }: { label: string; color: string }) {
  const colorMap: Record<string, string> = {
    green: 'bg-green-500/10 text-green-400 border-green-500/20',
    yellow: 'bg-yellow-500/10 text-yellow-400 border-yellow-500/20',
    blue: 'bg-blue-500/10 text-blue-400 border-blue-500/20',
  }
  return (
    <span className={`px-2.5 py-1 rounded-full text-xs font-medium border ${colorMap[color] ?? colorMap.blue} whitespace-nowrap`}>
      {label}
    </span>
  )
}

// MARK: - Data

interface Project {
  icon: string
  title: string
  status: string
  statusColor: 'green' | 'yellow' | 'blue'
  description: string
  tech: string[]
  githubPath?: string
}

const projects: Project[] = [
  {
    icon: '🎹',
    title: 'iOS Synthesizer',
    status: 'In Development',
    statusColor: 'green',
    description:
      'A touch- and sensor-controlled sound engine for iPhone/iPad. The XY performance pad maps finger position to pitch and filter cutoff. The accelerometer and gyroscope generate real-time MIDI CC modulation. A virtual MIDI port makes the app appear as an instrument in Ableton Live — no extra hardware required.',
    tech: ['Swift', 'SwiftUI', 'AudioKit', 'CoreMIDI', 'CoreMotion', 'iOS 16+'],
    githubPath: 'ios-synthesizer',
  },
  {
    icon: '🧠',
    title: 'Focus Ecosystem',
    status: 'Planning',
    statusColor: 'yellow',
    description:
      'A multi-format reading and knowledge management system that integrates AI and intelligent backlinking. Inspired by the Zettelkasten methodology — every note connects to other notes, surfacing unexpected relationships. AI features will suggest links, summarize reading sessions, and surface relevant past notes while you work.',
    tech: ['TypeScript', 'Next.js', 'AI/LLM', 'Graph DB', 'Zettelkasten'],
    githubPath: undefined,
  },
  {
    icon: '⚡',
    title: 'Symbolic Logic & Programming',
    status: 'Learning',
    statusColor: 'blue',
    description:
      'A hands-on learning track bridging formal symbolic logic with creative code. Currently exploring JavaScript and p5.js for generative visual art, and beginning VST plugin development for audio software. The goal is to move from design tools to building tools — understanding programming from first principles.',
    tech: ['JavaScript', 'p5.js', 'C++', 'JUCE (VST)'],
    githubPath: undefined,
  },
]
