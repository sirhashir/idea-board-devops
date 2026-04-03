export default function IdeaList({ ideas, loading, error }) {
  function getRelativeTime(dateString) {
    const now = new Date()
    const date = new Date(dateString)
    const seconds = Math.floor((now - date) / 1000)

    if (seconds < 60) return 'just now'
    if (seconds < 3600) {
      const mins = Math.floor(seconds / 60)
      return `${mins} ${mins === 1 ? 'minute' : 'minutes'} ago`
    }
    if (seconds < 86400) {
      const hours = Math.floor(seconds / 3600)
      return `${hours} ${hours === 1 ? 'hour' : 'hours'} ago`
    }
    if (seconds < 172800) return 'yesterday'
    const days = Math.floor(seconds / 86400)
    return `${days} days ago`
  }

  if (loading) {
    return (
      <div className="idea-list-container">
        <h2>Ideas</h2>
        <div className="skeleton-list">
          {[1, 2, 3].map(i => (
            <div key={i} className="skeleton-card" />
          ))}
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="idea-list-container">
        <h2>Ideas</h2>
        <div className="error-state">
          <p>Could not load ideas: {error}</p>
          <p>Make sure the backend is running.</p>
        </div>
      </div>
    )
  }

  if (ideas.length === 0) {
    return (
      <div className="idea-list-container">
        <h2>Ideas</h2>
        <div className="empty-state">
          <p>No ideas yet. Add your first one!</p>
        </div>
      </div>
    )
  }

  return (
    <div className="idea-list-container">
      <h2>Ideas <span className="idea-count">{ideas.length}</span></h2>
      <div className="idea-list">
        {ideas.map(idea => (
          <div key={idea.id} className="idea-card">
            <p className="idea-content">{idea.content}</p>
            <span className="idea-time">{getRelativeTime(idea.created_at)}</span>
          </div>
        ))}
      </div>
    </div>
  )
}