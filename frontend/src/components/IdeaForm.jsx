import { useState } from 'react'

export default function IdeaForm({ onIdeaAdded }) {
  const [content, setContent] = useState('')
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState(null)

  function handleSubmit(e) {
    e.preventDefault()
    if (!content.trim()) return

    setSubmitting(true)
    setError(null)

    fetch('/api/ideas', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ content: content.trim() })
    })
      .then(res => {
        if (!res.ok) throw new Error('Failed to submit idea')
        return res.json()
      })
      .then(newIdea => {
        setContent('')
        setSubmitting(false)
        onIdeaAdded(newIdea)
      })
      .catch(err => {
        setError(err.message)
        setSubmitting(false)
      })
  }

  return (
    <div className="idea-form-container">
      <h2>New Idea</h2>
      <form onSubmit={handleSubmit} className="idea-form">
        <textarea
          className="idea-textarea"
          placeholder="What's on your mind?"
          value={content}
          onChange={e => setContent(e.target.value)}
          maxLength={1000}
          rows={4}
          disabled={submitting}
        />
        <div className="form-footer">
          <span className="char-count">{content.length} / 1000</span>
          <button
            type="submit"
            className="submit-btn"
            disabled={!content.trim() || submitting}
          >
            {submitting ? 'Saving...' : 'Add Idea'}
          </button>
        </div>
        {error && <p className="form-error">{error}</p>}
      </form>
    </div>
  )
}