import { useState, useRef } from 'react'
import './App.css'

const BACKEND_URL = import.meta.env.VITE_BACKEND_URL

export default function App() {
  const [files, setFiles] = useState([])
  const [previews, setPreviews] = useState([])
  const [status, setStatus] = useState(null) // 'uploading' | 'success' | 'error'
  const [message, setMessage] = useState('')
  const [dragOver, setDragOver] = useState(false)
  const inputRef = useRef(null)

  function addFiles(incoming) {
    const imageFiles = incoming.filter(f => f.type.startsWith('image/'))
    if (imageFiles.length === 0) return
    setFiles(prev => [...prev, ...imageFiles])
    const newPreviews = imageFiles.map(f => ({
      name: f.name,
      url: URL.createObjectURL(f),
    }))
    setPreviews(prev => [...prev, ...newPreviews])
    setStatus(null)
    setMessage('')
  }

  function removeFile(index) {
    URL.revokeObjectURL(previews[index].url)
    setFiles(prev => prev.filter((_, i) => i !== index))
    setPreviews(prev => prev.filter((_, i) => i !== index))
  }

  function handleDrop(e) {
    e.preventDefault()
    setDragOver(false)
    addFiles(Array.from(e.dataTransfer.files))
  }

  async function handleUpload() {
    if (files.length === 0) return
    setStatus('uploading')
    setMessage('')

    const formData = new FormData()
    files.forEach(f => formData.append('images', f))
    console.log(formData)
    try {
      const res = await fetch(`${BACKEND_URL}/images/upload`, {
        method: 'POST',
        body: formData,
      })
      const data = await res.json().catch(() => ({}))
      if (res.ok) {
        setStatus('success')
        setMessage(data.message || `${files.length} image(s) uploaded successfully.`)
        setFiles([])
        previews.forEach(p => URL.revokeObjectURL(p.url))
        setPreviews([])
      } else {
        setStatus('error')
        setMessage(data.error || `Upload failed (${res.status}).`)
      }
    } catch (err) {
      setStatus('error')
      setMessage(`Could not reach the server: ${err.message}`)
    }
  }

  return (
    <div className="container">
      <h1>Image Upload</h1>
      <p className="subtitle">
        Backend: <code>{BACKEND_URL}</code>
      </p>

      <div
        className={`dropzone${dragOver ? ' drag-over' : ''}`}
        onClick={() => inputRef.current.click()}
        onDragOver={e => { e.preventDefault(); setDragOver(true) }}
        onDragLeave={() => setDragOver(false)}
        onDrop={handleDrop}
      >
        <input
          ref={inputRef}
          type="file"
          accept="image/*"
          multiple
          hidden
          onChange={e => addFiles(Array.from(e.target.files))}
        />
        <span>Click or drag &amp; drop images here</span>
      </div>

      {previews.length > 0 && (
        <div className="preview-grid">
          {previews.map((p, i) => (
            <div key={i} className="preview-card">
              <img src={p.url} alt={p.name} />
              <span className="preview-name">{p.name}</span>
              <button className="remove-btn" onClick={() => removeFile(i)}>&#10005;</button>
            </div>
          ))}
        </div>
      )}

      <button
        className="upload-btn"
        onClick={handleUpload}
        disabled={files.length === 0 || status === 'uploading'}
      >
        {status === 'uploading'
          ? 'Uploading…'
          : files.length > 0
            ? `Upload (${files.length})`
            : 'Upload'}
      </button>

      {message && (
        <p className={`feedback ${status}`}>{message}</p>
      )}
    </div>
  )
}
