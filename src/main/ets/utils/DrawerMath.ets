export function clamp(value: number, minValue: number, maxValue: number): number {
  if (value < minValue) {
    return minValue
  }
  if (value > maxValue) {
    return maxValue
  }
  return value
}

export function shouldCaptureVerticalDrag(offsetX: number, offsetY: number, threshold: number): boolean {
  if (Math.abs(offsetY) <= threshold) {
    return false
  }
  return Math.abs(offsetY) > Math.abs(offsetX)
}

export function shouldSyncOverlaySize(showMask: boolean, isDragging: boolean): boolean {
  return showMask && !isDragging
}
