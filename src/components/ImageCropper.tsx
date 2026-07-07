import React, { useState, useRef, useEffect, useCallback } from "react"
import { Button } from "./ui/button"
import { Slider } from "./ui/slider"
import { Loader2 } from "lucide-react"

interface ImageCropperProps {
  image: string
  onCropComplete: (croppedImage: Blob) => void
  onCancel: () => void
}

export const ImageCropper: React.FC<ImageCropperProps> = ({
  image,
  onCropComplete,
  onCancel,
}) => {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const [zoom, setZoom] = useState(1)
  const [position, setPosition] = useState({ x: 0, y: 0 })
  const [isDragging, setIsDragging] = useState(false)
  const [dragStart, setDragStart] = useState({ x: 0, y: 0 })
  const [img, setImg] = useState<HTMLImageElement | null>(null)
  const [isProcessing, setIsProcessing] = useState(false)

  // Load image
  useEffect(() => {
    const newImg = new Image()
    newImg.src = image
    newImg.crossOrigin = "anonymous"
    newImg.onload = () => {
      setImg(newImg)
      // Initial centered position
      setPosition({ x: 0, y: 0 })
    }
  }, [image])

  const draw = useCallback(() => {
    const canvas = canvasRef.current
    const ctx = canvas?.getContext("2d")
    if (!canvas || !ctx || !img) return

    // Clear canvas
    ctx.clearRect(0, 0, canvas.width, canvas.height)

    // Calculate dimensions to maintain aspect ratio and fill the "crop area"
    const size = canvas.width
    const imgAspect = img.width / img.height

    let drawWidth, drawHeight
    if (imgAspect > 1) {
      drawHeight = size * zoom
      drawWidth = drawHeight * imgAspect
    } else {
      drawWidth = size * zoom
      drawHeight = drawWidth / imgAspect
    }

    // Draw image centered + offset
    const x = (size - drawWidth) / 2 + position.x
    const y = (size - drawHeight) / 2 + position.y

    ctx.save()
    // Optional: Draw a circular mask preview on the canvas?
    // Usually easier to do with CSS overlays over the canvas.
    ctx.drawImage(img, x, y, drawWidth, drawHeight)
    ctx.restore()
  }, [img, zoom, position])

  useEffect(() => {
    draw()
  }, [draw])

  const handleMouseDown = (e: React.MouseEvent | React.TouchEvent) => {
    setIsDragging(true)
    const clientX = "touches" in e ? e.touches[0].clientX : e.clientX
    const clientY = "touches" in e ? e.touches[0].clientY : e.clientY
    setDragStart({ x: clientX - position.x, y: clientY - position.y })
  }

  const handleMouseMove = (e: React.MouseEvent | React.TouchEvent) => {
    if (!isDragging) return
    const clientX = "touches" in e ? e.touches[0].clientX : e.clientX
    const clientY = "touches" in e ? e.touches[0].clientY : e.clientY
    setPosition({
      x: clientX - dragStart.x,
      y: clientY - dragStart.y,
    })
  }

  const handleMouseUp = () => {
    setIsDragging(false)
  }

  const handleDone = async () => {
    const canvas = canvasRef.current
    if (!canvas || !img) return

    setIsProcessing(true)
    try {
      // Create a secondary canvas for the final export
      const exportCanvas = document.createElement("canvas")
      const size = 500 // Export size
      exportCanvas.width = size
      exportCanvas.height = size
      const eCtx = exportCanvas.getContext("2d")

      if (eCtx) {
        // We want to capture exactly what's visible in the UI "circle"
        // But the ui circle is the whole canvas square in this implementation logic
        const uiSize = canvas.width
        const imgAspect = img.width / img.height

        let drawWidth, drawHeight
        if (imgAspect > 1) {
          drawHeight = uiSize * zoom
          drawWidth = drawHeight * imgAspect
        } else {
          drawWidth = uiSize * zoom
          drawHeight = drawWidth / imgAspect
        }

        const scale = size / uiSize
        const x = ((uiSize - drawWidth) / 2 + position.x) * scale
        const y = ((uiSize - drawHeight) / 2 + position.y) * scale

        eCtx.drawImage(img, x, y, drawWidth * scale, drawHeight * scale)

        exportCanvas.toBlob(
          (blob) => {
            if (blob) onCropComplete(blob)
            setIsProcessing(false)
          },
          "image/jpeg",
          0.9
        )
      }
    } catch (err) {
      console.error(err)
      setIsProcessing(false)
    }
  }

  return (
    <div className="mx-auto flex w-full max-w-sm flex-col items-center gap-6">
      <div
        className="relative size-64 cursor-move overflow-hidden rounded-full border-4 border-primary/20 bg-muted shadow-xl md:size-80"
        onMouseDown={handleMouseDown}
        onMouseMove={handleMouseMove}
        onMouseUp={handleMouseUp}
        onMouseLeave={handleMouseUp}
        onTouchStart={handleMouseDown}
        onTouchMove={handleMouseMove}
        onTouchEnd={handleMouseUp}
      >
        <canvas
          ref={canvasRef}
          width={400}
          height={400}
          className="h-full w-full"
        />
        {/* Visual Guide Overlay */}
        <div className="pointer-events-none absolute inset-0 rounded-full ring-1 ring-white/20 ring-inset" />
      </div>

      <div className="w-full space-y-4">
        <div className="space-y-2">
          <div className="flex justify-between text-xs font-medium tracking-wider text-muted-foreground uppercase">
            <span>Zoom</span>
            <span>{Math.round(zoom * 100)}%</span>
          </div>
          <Slider
            min={1}
            max={3}
            step={0.01}
            value={[zoom]}
            onValueChange={(values) => setZoom(values[0])}
            className="py-2"
          />
        </div>

        <p className="text-center text-xs text-muted-foreground">
          Arraste a imagem para ajustar a posição dentro do círculo.
        </p>

        <div className="flex gap-3 pt-2">
          <Button
            variant="outline"
            className="flex-1"
            onClick={onCancel}
            disabled={isProcessing}
          >
            Cancelar
          </Button>
          <Button
            className="flex-1"
            onClick={handleDone}
            disabled={isProcessing || !img}
          >
            {isProcessing && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
            Confirmar
          </Button>
        </div>
      </div>
    </div>
  )
}
