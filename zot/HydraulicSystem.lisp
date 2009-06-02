;HydraulicSystem

(asdf:operate 'asdf:load-op 'bezot)
(use-package :trio-utils)


;Constants

(defvar noEvent 0)
(defvar handleDrive 1)
(defvar handlePark 2)
(defvar handleReverse 3)

(defvar TCUOneUp 1)
(defvar TCUTwoUp 2)
(defvar TCUOneDown 3)
(defvar TCUTwoDown 4)

(defvar shiftDrive 1)
(defvar shiftOneUp 2)
(defvar shiftTwoUp 3)
(defvar shiftOneDown 4)
(defvar shiftTwoDown 5)
(defvar shiftPark 6)
(defvar shiftReverse 7)

(defvar fluidPropagationDelay 1)

(defvar gearHandleDomain (loop for i from 0 to 3 collect i))
(defvar controlGearShiftDomain (loop for i from 0 to 4 collect i))
(defvar gearShiftDomain (loop for i from 0 to 7 collect i))

(define-variable gearHandle gearHandleDomain)
(define-variable controlGearShift controlGearShiftDomain)
(define-variable gearShift gearShiftDomain)




;Axioms

	;initial condition
 	(defvar init
  		(gearHandle-is handleDrive)
	)
	


	(defvar GearHandleCommand
    	 	(&& 
			(->	(gearHandle-is handleDrive)
				(&&
					(Lasts_ii(controlGearShift-is noEvent) fluidPropagationDelay)
					(Lasts(gearHandle-is noEvent) fluidPropagationDelay)
					(Futr(gearShift-is shiftDrive) fluidPropagationDelay)
				)
			)
			(->	(gearHandle-is handlePark)
				(&&
					(Lasts_ii(controlGearShift-is noEvent) fluidPropagationDelay)
					(Lasts(gearHandle-is noEvent) fluidPropagationDelay)
					(Futr(gearShift-is shiftPark) fluidPropagationDelay)
				)
			)
			(->	(gearHandle-is handleReverse)
				(&&
					(Lasts_ii(controlGearShift-is noEvent) fluidPropagationDelay)
					(Lasts(gearHandle-is noEvent) fluidPropagationDelay)
					(Futr(gearShift-is shiftReverse) fluidPropagationDelay)
				)
			)
		)
	)

	
	(defvar PropagateGearShiftCommand
		(->
			(||	(controlGearShift-is TCUOneUp)
				(controlGearShift-is TCUTwoUp)
				(controlGearShift-is TCUOneDown)
				(controlGearShift-is TCUTwoDown)
			)
			(&&
				(&&	(Lasts(controlGearShift-is noEvent) fluidPropagationDelay)
					(controlGearShift-is noEvent
				)
				(Lasts(gearHandle-is noEvent) fluidPropagationDelay)
				(->	(controlGearShift-is TCUOneUp)
					(Futr(gearShift-is shiftOneUp) fluidPropagationDelay)
				)
				(->	(controlGearShift-is TCUTwoUp)
					(Futr(gearShift-is shiftTwoUp) fluidPropagationDelay)
				)
				(->	(controlGearShift-is TCUOneDown)
					(Futr(gearShift-is shiftOneDown) fluidPropagationDelay)
				)
				(->	(controlGearShift-is TCUTwoDown)
					(Futr(gearShift-is shiftTwoDown) fluidPropagationDelay)
				)
			)
		)	
	)





