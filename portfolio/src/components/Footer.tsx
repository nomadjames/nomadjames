// Footer.tsx — Site footer

export default function Footer() {
  return (
    <footer className="border-t border-zinc-800 py-8 mt-16">
      <div className="container-md flex flex-col sm:flex-row items-center justify-between gap-4">
        <p className="text-xs text-zinc-600 font-mono">
          © {new Date().getFullYear()} James Dishman
        </p>
        <p className="text-xs text-zinc-600">
          Pittsburgh, PA · Kent State University
        </p>
      </div>
    </footer>
  )
}
