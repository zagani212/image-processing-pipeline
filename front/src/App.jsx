import { useState, useRef, useEffect, useCallback } from 'react'
import './App.css'

const WS_URL = import.meta.env.VITE_WS_URL
const BACKEND_URL = import.meta.env.VITE_BACKEND_URL

export default function App() {
  const [wsStatus, setWsStatus] = useState('disconnected')
  const [connectionId, setConnectionId] = useState(null)
  const [files, setFiles] = useState([])
  const [previews, setPreviews] = useState([])
  const [uploadStatus, setUploadStatus] = useState(null) // null | 'uploading' | 'sent' | 'error'
  const [message, setMessage] = useState('')
  const [dragOver, setDragOver] = useState(false)
  const [generated, setGenerated] = useState({ thumbnail: null, medium: null })
  const inputRef = useRef(null)
  const wsRef = useRef(null)

  const connect = useCallback(() => {
    if (!WS_URL) return
    if (wsRef.current && wsRef.current.readyState < 2) wsRef.current.close()

    setWsStatus('connecting')
    setConnectionId(null)
    const ws = new WebSocket(WS_URL)
    wsRef.current = ws

    ws.onopen = () => {
      setWsStatus('connected')
      ws.send(JSON.stringify({
        action: 'getConnectionId',
      }))
    }

    ws.onmessage = (event) => {
      try {
        console.log(event)
        const data = JSON.parse(event.data)
        console.log(data) //"CONNECTION_ACK"
        console.log(data.type)
        console.log(data.type === 'CONNECTION_ACK')
        if (data.type === 'CONNECTION_ACK') {
          setConnectionId(data.connectionId)
          console.log(this.connectionId)
        } else if (data.type === 'THUMBNAIL_GENERATED') {
          setGenerated(prev => ({ ...prev, thumbnail: data.url }))
        } else if (data.type === 'WATERMARK_GENERATED') {
          setGenerated(prev => ({ ...prev, watermark: data.url }))
        } else if (data.type === 'MEDIUM_GENERATED') {
          setGenerated(prev => ({ ...prev, medium: data.url }))
        }
      } catch {}
    }

    ws.onclose = () => {
      setWsStatus('disconnected')
      setConnectionId(null)
    }

    ws.onerror = () => setWsStatus('disconnected')
  }, [])

  useEffect(() => {
    //connect()
    return () => wsRef.current?.close()
  }, [connect])

  function addFiles(incoming) {
    const images = incoming.filter(f => f.type.startsWith('image/'))
    if (!images.length) return
    setFiles(prev => [...prev, ...images])
    setPreviews(prev => [
      ...prev,
      ...images.map(f => ({ name: f.name, url: URL.createObjectURL(f) })),
    ])
    setUploadStatus(null)
    setMessage('')
    setGenerated({ thumbnail: null, medium: null })
  }

  function removeFile(index) {
    URL.revokeObjectURL(previews[index].url)
    setFiles(prev => prev.filter((_, i) => i !== index))
    setPreviews(prev => prev.filter((_, i) => i !== index))
  }

  async function handleUpload() {
    const ws = wsRef.current
    if (!files.length || !ws || ws.readyState !== WebSocket.OPEN) return

    setUploadStatus('uploading')
    setMessage('')
    setGenerated({ thumbnail: null, medium: null })

    const formData = new FormData()
    files.forEach(f => formData.append('images', f))
    try {
      const res = await fetch(`${BACKEND_URL}/images/upload`, {
        method: 'POST',
        headers: {
          connectionId
        },
        body: formData,
      })

      setUploadStatus('sent')
      setMessage('Image sent — waiting for processed results…')
      previews.forEach(p => URL.revokeObjectURL(p.url))
      setFiles([])
      setPreviews([])
    } catch (err) {
      setUploadStatus('error')
      setMessage(`Failed to send: ${err.message}`)
    }
  }

  const isReady = wsStatus === 'connected' && files.length > 0 && uploadStatus !== 'uploading'
  const isWaiting = uploadStatus === 'sent' && !generated.thumbnail && !generated.medium

  return (
    <div className="container">
      <h1>Image Upload</h1>

      <div className={`ws-badge ws-${wsStatus}`}>
        <span className="ws-dot" />
        {wsStatus === 'connected'
          ? 'Connected'
          : wsStatus === 'connecting'
            ? 'Connecting…'
            : 'Disconnected'}
        {wsStatus === 'disconnected' && (
          <button className="reconnect-btn" onClick={connect}>Reconnect</button>
        )}
      </div>

      <div
        className={`dropzone${dragOver ? ' drag-over' : ''}`}
        onClick={() => inputRef.current.click()}
        onDragOver={e => { e.preventDefault(); setDragOver(true) }}
        onDragLeave={() => setDragOver(false)}
        onDrop={e => { e.preventDefault(); setDragOver(false); addFiles(Array.from(e.dataTransfer.files)) }}
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
        disabled={!isReady}
      >
        {uploadStatus === 'uploading'
          ? 'Sending…'
          : files.length > 0
            ? `Upload (${files.length})`
            : 'Upload'}
      </button>

      {message && (
        <p className={`feedback ${uploadStatus}`}>{message}</p>
      )}

      {isWaiting && (
        <div className="generated-section">
          <h2>Processing</h2>
          <div className="generated-grid">
            <div className="generated-card placeholder">
              <span className="generated-label">Thumbnail</span>
              <div className="spinner" />
            </div>
            <div className="generated-card placeholder">
              <span className="generated-label">Medium</span>
              <div className="spinner" />
            </div>
          </div>
        </div>
      )}

      {(generated.thumbnail || generated.medium) && (
        <div className="generated-section">
          <h2>Generated Images</h2>
          <div className="generated-grid">
            <div className={`generated-card${generated.thumbnail ? '' : ' placeholder'}`}>
              <span className="generated-label">WaterMark</span>
              {generated.thumbnail
                ? <img src={generated.watermark} alt="Watermark" />
                : <div className="spinner" />}
            </div>
            <div className={`generated-card${generated.thumbnail ? '' : ' placeholder'}`}>
              <span className="generated-label">Thumbnail</span>
              {generated.thumbnail
                ? <img src={generated.thumbnail} alt="Thumbnail" />
                : <div className="spinner" />}
            </div>
            <div className={`generated-card${generated.medium ? '' : ' placeholder'}`}>
              <span className="generated-label">Medium</span>
              {generated.medium
                ? <img src={generated.medium} alt="Medium" />
                : <div className="spinner" />}
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

function fileToBase64(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = () => resolve(reader.result.split(',')[1])
    reader.onerror = reject
    reader.readAsDataURL(file)
  })
}
