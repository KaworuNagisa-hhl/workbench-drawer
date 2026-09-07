import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { clamp, shouldCaptureVerticalDrag, shouldSyncOverlaySize } from '../main/ets/utils/DrawerMath'

export default function localUnitTest() {
  describe('localUnitTest', () => {
    beforeAll(() => {
    });
    beforeEach(() => {
    });
    afterEach(() => {
    });
    afterAll(() => {
    });
    it('assertContain', 0, () => {
      let a = 'abc';
      let b = 'b';
      expect(a).assertContain(b);
      expect(a).assertEqual(a);
    });

    it('shouldCaptureVerticalDrag_only_when_vertical_move_dominates_and_exceeds_threshold', 0, () => {
      expect(shouldCaptureVerticalDrag(2, 12, 5)).assertTrue()
      expect(shouldCaptureVerticalDrag(12, 12, 5)).assertFalse()
      expect(shouldCaptureVerticalDrag(20, 12, 5)).assertFalse()
      expect(shouldCaptureVerticalDrag(1, 4, 5)).assertFalse()
    });

    it('clamp_keeps_height_within_bounds', 0, () => {
      expect(clamp(50, 60, 100)).assertEqual(60)
      expect(clamp(80, 60, 100)).assertEqual(80)
      expect(clamp(120, 60, 100)).assertEqual(100)
    });

    it('shouldSyncOverlaySize_only_when_mask_is_fullscreen_and_not_dragging', 0, () => {
      expect(shouldSyncOverlaySize(false, false)).assertFalse()
      expect(shouldSyncOverlaySize(false, true)).assertFalse()
      expect(shouldSyncOverlaySize(true, true)).assertFalse()
      expect(shouldSyncOverlaySize(true, false)).assertTrue()
    });
  });
}
