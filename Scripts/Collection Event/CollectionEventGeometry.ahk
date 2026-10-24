#Requires AutoHotkey v2.0

; Shared by bonus selection and event-only map clicks. The small map captures
; belong to thumbnail artwork, never the similar shapes in the medal strip.

GetCollectionEventCardRegions() {
    ; The gaps between cards are deliberately unassigned.
    return [
        {left: 350, top: 118, right: 725, bottom: 416},
        {left: 775, top: 118, right: 1150, bottom: 416},
        {left: 1198, top: 118, right: 1575, bottom: 416},
        {left: 350, top: 434, right: 725, bottom: 740},
        {left: 775, top: 434, right: 1150, bottom: 740},
        {left: 1198, top: 434, right: 1575, bottom: 740}
    ]
}

GetCollectionEventCardIndex(x, y) {
    for index, card in GetCollectionEventCardRegions() {
        if x >= card.left && x <= card.right && y >= card.top && y <= card.bottom
            return index
    }
    return 0
}

GetCollectionEventMapMatchCard(match, offsetX := 0, offsetY := 0) {
    cardIndex := GetCollectionEventCardIndex(match.x + offsetX, match.y + offsetY)
    if !cardIndex
        return 0
    ; The photographed layout leaves the upper thumbnail area unobscured by medals.
    ; Requiring the complete sample here rejects medal-edge lookalikes even when
    ; their center still falls inside the larger card envelope.
    image := GetCollectionEventMapArtRegion(cardIndex)
    left := match.1 + offsetX
    top := match.2 + offsetY
    right := left + match.3 - 1
    bottom := top + match.4 - 1
    return left >= image.left && top >= image.top && right <= image.right && bottom <= image.bottom
        ? cardIndex : 0
}

IsCollectionEventMapArtMatch(match, offsetX := 0, offsetY := 0) {
    return GetCollectionEventMapMatchCard(match, offsetX, offsetY) > 0
}

GetCollectionEventMapArtRegion(cardIndex) {
    card := GetCollectionEventCardRegions()[cardIndex]
    return {left: card.left + 18, top: card.top + 26, right: card.right - 18, bottom: card.top + 208}
}

GetCollectionEventBadgeSearchRegion(cardIndex) {
    card := GetCollectionEventCardRegions()[cardIndex]
    ; The badge sits on the right edge. Leave room for the full 63-pixel capture
    ; even when its center extends a little beyond the card border.
    return {left: card.right - 132, top: card.top, right: card.right + 64, bottom: card.bottom}
}

GetCollectionEventBadgeCardIndex(x, y) {
    for index, card in GetCollectionEventCardRegions() {
        if x >= card.right - 100 && x <= card.right + 30 && y >= card.top && y <= card.bottom
            return index
    }
    return 0
}
