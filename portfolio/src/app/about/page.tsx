// about/page.tsx — About James

import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'About — James Dishman',
}

export default function AboutPage() {
  return (
    <div className="container-md py-20">

      <p className="section-label mb-4">Background</p>
      <h1 className="text-3xl md:text-4xl font-semibold text-white mb-10">About</h1>

      {/* Bio */}
      <div className="prose prose-invert max-w-none mb-16">
        <p className="text-zinc-300 text-lg leading-relaxed mb-6">
          I&apos;m James Dishman — a UX researcher, designer, and developer-in-progress
          based in Pittsburgh, PA. My work sits at the intersection of{' '}
          <strong className="text-white">human-computer interaction</strong>,{' '}
          <strong className="text-white">AI-enhanced creativity</strong>, and{' '}
          <strong className="text-white">community building</strong>.
        </p>
        <p className="text-zinc-400 leading-relaxed mb-6">
          I&apos;m currently pursuing my{' '}
          <strong className="text-white">Master of Science in User Experience at Kent State University</strong>,
          where I focus on designing intelligent systems that augment human thinking
          rather than replacing it.
        </p>
        <p className="text-zinc-400 leading-relaxed">
          Outside of academia, I co-founded the{' '}
          <strong className="text-white">Pittsburgh Ableton User Group</strong> —
          a community of electronic musicians, sound designers, and creative technologists
          who gather to share knowledge and collaborate. This community inspires much of my
          work on the iOS Synthesizer and my interest in performance interfaces.
        </p>
      </div>

      {/* Skills grid */}
      <p className="section-label mb-6">Skills & Interests</p>
      <div className="grid gap-4 md:grid-cols-2 mb-16">
        {skills.map((skill) => (
          <div key={skill.category} className="p-5 rounded-xl bg-zinc-900 border border-zinc-800">
            <p className="text-accent font-mono text-sm mb-3">{skill.category}</p>
            <ul className="space-y-1">
              {skill.items.map((item) => (
                <li key={item} className="text-zinc-400 text-sm flex items-center gap-2">
                  <span className="w-1 h-1 rounded-full bg-zinc-600 flex-shrink-0" />
                  {item}
                </li>
              ))}
            </ul>
          </div>
        ))}
      </div>

      {/* Currently learning */}
      <p className="section-label mb-6">Currently Learning</p>
      <div className="flex flex-wrap gap-3">
        {learning.map((item) => (
          <span
            key={item}
            className="px-4 py-2 rounded-xl border border-zinc-700 bg-zinc-900 text-zinc-300 text-sm font-mono"
          >
            {item}
          </span>
        ))}
      </div>

    </div>
  )
}

const skills = [
  {
    category: 'User Experience Design',
    items: ['User Research & Interviews', 'Interaction Design', 'Wireframing & Prototyping', 'Usability Testing', 'Information Architecture'],
  },
  {
    category: 'AI & Knowledge Management',
    items: ['Zettelkasten Methodology', 'Intelligent Systems Design', 'LLM Application Design', 'Personal Knowledge Management (PKM)'],
  },
  {
    category: 'Creative Technology',
    items: ['Audio Synthesis', 'Modular Synthesis', 'Ableton Live', 'iOS App Development (learning)', 'Digital Art'],
  },
  {
    category: 'Community & Research',
    items: ['Community Organizing', 'Digital Collaboration', 'Open Innovation', 'Academic Research'],
  },
]

const learning = ['JavaScript', 'TypeScript', 'Swift', 'p5.js', 'React', 'Next.js', 'AudioKit', 'C++ / JUCE']
