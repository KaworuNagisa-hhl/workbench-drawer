export enum DrawerSnapMode {
  /** 松手后按拖动方向展开或收起 */
  Direction = 0,
  /** 松手后超过展开高度一半则展开，否则收起 */
  Half = 1,
  /** 同时满足方向手势和一半高度规则 */
  DirectionAndHalf = 2
}
