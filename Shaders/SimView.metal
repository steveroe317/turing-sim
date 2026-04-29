//
//  SimView.metal
//  TuringSim
//
//  Created by Steve Roe on 1/6/26.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 checkerboard(float2 position, half4 currentColor, float size, half4 newColor) {
    uint2 posInChecks = uint2(position.x / size, position.y / size);
    bool isColor = (posInChecks.x ^ posInChecks.y) & 1;
    return isColor ? newColor * half4(1.0, 1.0, 1.0, 0.5) : currentColor;
}

[[ stitchable ]] half4 passthrough(float2 position, half4 currentColor) {
    return currentColor;
}

[[ stitchable ]] half4 turingdrawblock(float2 position, half4 currentColor,
                                  float2 size,
                                  float simWidth,
                                  const device half4* colors,
                                  int count) {
    
    float2 simCellPoint = (position / size) * simWidth;
    
    int simCellOffset = int(simCellPoint.x) * simWidth + int(simCellPoint.y);

    half4 color = colors[simCellOffset];
    //color = (int(simCellPoint.x) + int(simCellPoint.y)) % 2 ? half4(0.5, 0.5, 0.5, 1.0) : color;
    return color;
}

[[ stitchable ]] half4 turingdrawsmooth(float2 position, half4 currentColor,
                                  float2 size,
                                  float simWidth,
                                  const device half4* colors,
                                  int count) {
    
    int simEdgeCount = round(simWidth);
    float2 cellSize = size / simEdgeCount;
    float2 simPoint = (position / size) * simWidth;
    int2 simCellIndex = int2(simPoint);
    float2 cellPoint = fract(simPoint) * cellSize;
    
    int dx = (cellPoint.x < 0.5 * cellSize.x) ? -1 : 1;
    int dy = (cellPoint.y < 0.5 * cellSize.y) ? -1 : 1;
    
    int2 horizontalNeighborIndex = (simCellIndex + int2(dx, 0) + simEdgeCount) % simEdgeCount;
    int2 verticalNeighborIndex = (simCellIndex + int2(0, dy) + simEdgeCount) % simEdgeCount;
    int2 diagonalNeighborIndex = (simCellIndex + int2(dx, dy) + simEdgeCount) % simEdgeCount;
    
    // The sign of these deltas does not matter as they are used only in
    // vector length calculations.
    float innerPegDeltaX = cellPoint.x - 0.5 * cellSize.x;
    float innerPegDeltaY = cellPoint.y - 0.5 * cellSize.x;
    
    float outerPegDeltaX = (dx < 0) ? cellPoint.x + 0.5 * cellSize.x : cellPoint.x - 1.5 * cellSize.x;
    float outerPegDeltaY = (dy < 0) ? cellPoint.y + 0.5 * cellSize.y : cellPoint.y - 1.5 * cellSize.y;
    
    float simPegDistance = length(float2(innerPegDeltaX, innerPegDeltaY));
    float horizontalPegDistance = length(float2(outerPegDeltaX, innerPegDeltaY));
    float verticalPegDistance = length(float2(innerPegDeltaX, outerPegDeltaY));
    float diagonalPegDistance = length(float2(outerPegDeltaX, outerPegDeltaY));

    float fadeDistance = 1.0 * min(cellSize.x, cellSize.y);
    float simPegWeight = 1 - smoothstep(0.0, fadeDistance, simPegDistance);
    float horizontalPegWeight = 1 - smoothstep(0.0, fadeDistance, horizontalPegDistance);
    float verticalPegWeight = 1 - smoothstep(0.0, fadeDistance, verticalPegDistance);
    float diagonalPegWeight = 1 - smoothstep(0.0, fadeDistance, diagonalPegDistance);
    float totalWeight = simPegWeight + horizontalPegWeight + verticalPegWeight + diagonalPegWeight;
    
    int simCellOffset = simCellIndex.x * simEdgeCount + simCellIndex.y;
    int horizontalBlendOffset = horizontalNeighborIndex.x * simEdgeCount + horizontalNeighborIndex.y;
    int verticalBlendOffset = verticalNeighborIndex.x * simEdgeCount + verticalNeighborIndex.y;
    int diagonalBlendOffset = diagonalNeighborIndex.x * simEdgeCount + diagonalNeighborIndex.y;

    half4 color = (colors[simCellOffset] * simPegWeight
        + colors[horizontalBlendOffset] * horizontalPegWeight
        + colors[verticalBlendOffset] * verticalPegWeight
        + colors[diagonalBlendOffset] * diagonalPegWeight) / totalWeight;
    
//    half4 radialColor = half4(simPegDistance/cellSize.x, simPegDistance/cellSize.x, 0, 1);
//    half4 centerStripeXColor = half4(abs(innerPegDeltaX)/cellSize.x, 0, 0, 1);
//    half4 centerStripeYColor = half4(0, abs(innerPegDeltaX)/cellSize.y, 0, 1);
//    color = (simCellIndex.x + simCellIndex.y) % 2 ? half4(0, 0, 0, 1) : centerStripeYColor;

    return color;
}

