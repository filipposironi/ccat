;PlanetaryGearSet

(asdf:operate 'asdf:load-op 'bezot)
(use-package :trio-utils)


;Constants

(defvar singleGearShiftDelay 2)
(defvar dualGearShiftDelay 3)
(defvar driveGearShiftDelay 3)
(defvar parkGearShiftDelay 3)
(defvar reverseGearShiftDelay 3)

(defvar noEvent 0)
(defvar shiftDrive 1)
(defvar shiftOneUp 2)
(defvar shiftTwoUp 3)
(defvar shiftOneDown 4)
(defvar shiftTwoDown 5)
(defvar shiftPark 6)
(defvar shiftReverse 7)

(defvar first 1)
(defvar second 2)
(defvar third 3)
(defvar park 4)
(defvar reverse 5) 

(defvar detached 0)
(defvar attached 1)
	

(defvar actualGearDomain (loop for i from 1 to 5 collect i))
(defvar gearShiftDomain (loop for i from 0 to 7 collect i))

;transmissionShiftState:[0..1],

(define-variable actualGear actualGearDomain)
(define-variable gearShift gearShiftDomain)


			
;axioms

	;initial condition
 	(defvar init
  	(actualGear-is first))
	
	(defvar Mechanics
		(->	(||(gearShift-is shiftOneUp)(gearShift-is shiftTwoUp))
			(-P- transmissionShaftState)
		)
	)

	(defvar GearShiftDrive
		(->	(gearShift-is shiftDrive)
			(!! (-P- transmissionShaftState))
		)
	)
	
	(defvar GearShiftFirst
		(&&	(->	(actualGear-is first)
				(||(gearShift-is noEvent)(gearShift-is shiftOneUp)(gearShift-is 				shiftTwoUp)(gearShift-is shiftPark)(gearShift-is shiftReverse))
			)
			(->	(&&(actualGear-is first)(gearShift-is shiftOneUp))
				(&&(Lasts_ei(gearShift-is noEvent) singleGearShiftDelay)(Futr(actualGear-is second)  					singleGearShiftDelay))
			)
			(->	(&&(actualGear-is first)(gearShift-is shiftTwoUp))
				(&&(Lasts_ei(gearShift-is noEvent) dualGearShiftDelay)(Futr(actualGear-is third)  					dualGearShiftDelay))
			)
			(->	(&&(actualGear-is first)(gearShift-is shiftPark))
				(&&(Lasts_ei(gearShift-is noEvent) parkGearShiftDelay)(Futr(actualGear-is park)  					parkGearShiftDelay))
			)
			(->	(&&(actualGear-is first)(gearShift-is shiftReverse))
				(&&(Lasts_ei(gearShift-is noEvent) reverseGearShiftDelay)(Futr(actualGear-is reverse)  					reverseGearShiftDelay))
			)
		)
	)


	(defvar GearShiftSecond
		(&&	(->	(actualGear-is second)
				(||(gearShift-is noEvent)(gearShift-is shiftOneUp)(gearShift-is shiftOneDown))
			)
			(->	(&&(actualGear-is second)(gearShift-is shiftOneUp))
				(&&(Lasts_ei(gearShift-is noEvent) singleGearShiftDelay)(Futr(actualGear-is third)  					singleGearShiftDelay))
			)
			(->	(&&(actualGear-is second)(gearShift-is shiftOneDown))
				(&&(Lasts_ei(gearShift-is noEvent) singleGearShiftDelay)(Futr(actualGear-is first)  					singleGearShiftDelay))
			)
		)
	)


	(defvar GearShiftThird
		(&&	(->	(actualGear-is third)
				(||(gearShift-is noEvent)(gearShift-is shiftOneDown)(gearShift-is shiftTwoDown))
			)
			(->	(&&(actualGear-is third)(gearShift-is shiftOneDown))
				(&&(Lasts_ei(gearShift-is noEvent) singleGearShiftDelay)(Futr(actualGear-is second)  					singleGearShiftDelay))
			)
			(->	(&&(actualGear-is third)(gearShift-is shiftTwoDown))
				(&&(Lasts_ei(gearShift-is noEvent) dualGearShiftDelay)(Futr(actualGear-is first)  					dualGearShiftDelay))
			)
		)
	)

	(defvar GearShiftReverse
		(&&	(->	(actualGear-is reverse)
				(||(gearShift-is noEvent)(gearShift-is shiftDrive)(gearShift-is shiftPark))
			)
			(->	(&&(actualGear-is reverse)(gearShift-is shiftDrive))
				(&&(Lasts_ei(gearShift-is noEvent) driveGearShiftDelay)(Futr(actualGear-is first)  					driveGearShiftDelay))
			)
			(->	(&&(actualGear-is reverse)(gearShift-is shiftPark))
				(&&(Lasts_ei(gearShift-is noEvent) parkGearShiftDelay)(Futr(actualGear-is park)  					parkGearShiftDelay))
			)
			(->	(gearShift-is shiftReverse)
				(!! (-P-  transmissionShaftState))
			)
		)
	)

	(defvar GearShiftPark
		(&&	(->	(actualGear-is park)
				(!! (-P- transmissionShaftState))
			)
			(->	(actualGear-is park)
				(||(gearShift-is noEvent)(gearShift-is shiftDrive)(gearShift-is shiftReverse))
			)
			(->	(&&(actualGear-is park)(gearShift-is shiftDrive))
				(&&(Lasts_ei(gearShift-is noEvent) driveGearShiftDelay)(Futr(actualGear-is first)  					driveGearShiftDelay))
			)
			(->	(&&(actualGear-is park)(gearShift-is shiftReverse))
				(&&(Lasts_ei(gearShift-is noEvent) reverseGearShiftDelay)(Futr(actualGear-is reverse)  					reverseGearShiftDelay))
			)
			(->	(gearShift-is shiftReverse)
				(!! (-P-  transmissionShaftState))
			)
		)
	)


	
