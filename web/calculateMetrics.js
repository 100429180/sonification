//================================================= CÁLCULO DE MÉTRICAS =============================================================
function calculateMetrics(partName) {
    if (poseHistory.length >= 5) {
        const currentPose = poseHistory[0].pose;
        const prevPose = poseHistory[1].pose;
        const prevPrevPose = poseHistory[2].pose;
        const prevPrevPrevPose = poseHistory[3].pose;
        const prevPrevPrevPrevPose = poseHistory[4].pose;

        let currentX = 0;
        let currentY = 0;
        let prevX = 0;
        let prevY = 0;
        let prevPrevX = 0;
        let prevPrevY = 0;
        let prevPrevPrevX = 0;
        let prevPrevPrevY = 0;
        let prevPrevPrevPrevX = 0;
        let prevPrevPrevPrevY = 0;
        let frameRate = 30;
        let deltaT = 1 / frameRate;

        if (currentPose && prevPose && prevPrevPose && prevPrevPrevPose && prevPrevPrevPrevPose) {
            const currentPart = currentPose.keypoints.find(keypoint => keypoint.part === partName);
            const prevPart = prevPose.keypoints.find(keypoint => keypoint.part === partName);
            const prevPrevPart = prevPrevPose.keypoints.find(keypoint => keypoint.part === partName);
            const prevPrevPrevPart = prevPrevPrevPose.keypoints.find(keypoint => keypoint.part === partName);
            const prevPrevPrevPrevPart = prevPrevPrevPrevPose.keypoints.find(keypoint => keypoint.part === partName);

            if (currentPart && prevPart && prevPrevPart && prevPrevPrevPart && prevPrevPrevPrevPart) {
                if (currentPart.score >= 0 && prevPart.score >= 0) { // Si la score no es mayor del umbral, fija las coordenadas en cero.
                    currentX = currentPart.position.x;
                    currentY = currentPart.position.y;
                    prevX = prevPart.position.x;
                    prevY = prevPart.position.y;
                } else {
                    currentX = 0;
                    currentY = 0;
                    prevX = 0;
                    prevY = 0;
                }

                // =============================================== DESPLAZAMIENTO ===============================================
                const deltaX = currentX - prevX; // desplazamiento en X
                const deltaY = currentY - prevY; // desplazamiento en Y
                const displacement = Math.sqrt(deltaX * deltaX + deltaY * deltaY); // desplazamiento total 

                const displacementElement = document.getElementById(`${partName}Displacement`);
                displacementElement.textContent = `${partName} Displacement: ${displacement.toFixed(2)} pixels`;

                // =============================================== VELOCIDAD =====================================================
                const velocity = displacement/deltaT;

                const velocityElement = document.getElementById(`${partName}Velocity`);
                velocityElement.textContent = `${partName} Velocity: ${velocity.toFixed(2)} pixels/s`;

                // =============================================== ACELERACIÓN ====================================================
                
                if (prevPrevPart.score >= 0) {
                    prevPrevX = prevPrevPart.position.x;
                    prevPrevY = prevPrevPart.position.y;
                } else {
                    prevPrevX = 0;
                    prevPrevY = 0;
                }
                const prevDeltaX = prevX - prevPrevX;
                const prevDeltaY = prevY - prevPrevY;
                const prevDisplacement = Math.sqrt((prevDeltaX * prevDeltaX) + (prevDeltaY * prevDeltaY));
                const prevVelocity = prevDisplacement / deltaT;
                const acceleration = Math.abs((velocity - prevVelocity) / deltaT);

                const accelerationElement = document.getElementById(`${partName}Acceleration`);
                accelerationElement.textContent = `${partName} Acceleration: ${acceleration.toFixed(2)} pixels/s²`;

                // =============================================== JERK ===============================================

                if (prevPrevPrevPart.score >= 0) {
                    prevPrevPrevX = prevPrevPrevPart.position.x;
                    prevPrevPrevY = prevPrevPrevPart.position.y;
                } else {
                    prevPrevPrevX = 0;
                    prevPrevPrevY = 0;
                }

                const prevPrevDeltaX = prevPrevX - prevPrevPrevX;
                const prevPrevDeltaY = prevPrevY - prevPrevPrevY;
                const prevPrevDisplacement = Math.sqrt(prevPrevDeltaX * prevPrevDeltaX + prevPrevDeltaY * prevPrevDeltaY);
                const prevPrevVelocity = prevPrevDisplacement / deltaT;
                const prevAcceleration = (prevVelocity - prevPrevVelocity) / deltaT;
                const jerk = Math.abs((acceleration - prevAcceleration) / deltaT);

                const jerkElement = document.getElementById(`${partName}Jerk`);
                jerkElement.textContent = `${partName} Jerk: ${jerk.toFixed(2)} pixels/s³`;

                // =============================================== SNAP ===============================================

                if (prevPrevPrevPrevPart.score >= 0) {
                    prevPrevPrevPrevX = prevPrevPrevPrevPart.position.x;
                    prevPrevPrevPrevY = prevPrevPrevPrevPart.position.y;
                } else {
                    prevPrevPrevPrevX = 0;
                    prevPrevPrevPrevY = 0;
                }

                const prevPrevPrevDeltaX = prevPrevPrevX - prevPrevPrevPrevX;
                const prevPrevPrevDeltaY = prevPrevPrevY - prevPrevPrevPrevY;
                const prevPrevPrevDisplacement = Math.sqrt(prevPrevPrevDeltaX * prevPrevPrevDeltaX + prevPrevPrevDeltaY * prevPrevPrevDeltaY);
                const prevPrevPrevVelocity = prevPrevPrevDisplacement / deltaT;
                const prevPrevAcceleration = (prevPrevVelocity - prevPrevPrevVelocity) / deltaT;
                const prevJerk = (prevAcceleration - prevPrevAcceleration)/ deltaT;
                const snap = Math.abs((jerk - prevJerk) / deltaT);

                const snapElement = document.getElementById(`${partName}Snap`);
                snapElement.textContent = `${partName} Snap: ${snap.toFixed(2)} pixels/s⁴`;

                const metricsResults = [displacement, velocity, acceleration, jerk, snap, currentX, currentY];


                return metricsResults;
            }
        }
    }
}
