import { useState, useEffect } from 'react'
import IdeaForm from './components/IdeaForm'
import IdeaList from './components/IdeaList'

export default function App() {
  const [ideas, setIdeas] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [refreshTrigger, setRefreshTrigger] = useState(0)

  useEffect(() => {
    setLoading(true)
    setError(null)

    fetch('/api/ideas')
      .then(res => {
        if (!res.ok) throw new Error('Failed to fetch ideas')
        return res.json()
      })
      .then(data => {
        setIdeas(data)
        setLoading(false)
      })
      .catch(err => {
        setError(err.message)
        setLoading(false)
      })
  }, [refreshTrigger])

  function handleIdeaAdded(newIdea) {
    setRefreshTrigger(prev => prev + 1)
  }

  return (
    <div className="app">
      <header className="app-header">
        <h1>Idea Board</h1>
        <p>Capture your thoughts before they disappear</p>
      </header>
      <main className="app-main">
        <IdeaForm onIdeaAdded={handleIdeaAdded} />
        <IdeaList ideas={ideas} loading={loading} error={error} />
      </main>
    </div>
  )
}