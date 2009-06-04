(asdf:operate 'asdf:load-op 'bezot)
(use-package :trio-utils)

; Constants
(defvar Nothing 0)

(defvar TCUOneUp 1)
(defvar TCUOneDown 2)

(defvar HandleDrive 1)
(defvar HandlePark 2)
(defvar HandleReverse 3)

(defvar ShiftOneUp 1)
(defvar ShiftOneDown 2)
(defvar ShiftDrive 3)
(defvar ShiftPark 4)
(defvar ShiftReverse 5)

(defvar First 0)
(defvar Second 1)
(defvar Park 2)
(defvar Reverse 3)

(defvar Detached 0)
(defvar Attached 1)

(defvar FluidPropagationDelay 1)

(defvar SingleGearShiftDelay 2)
(defvar DriveGearShiftDelay 3)
(defvar ParkGearShiftDelay 3)
(defvar ReverseGearShiftDelay 3)

; Domains
(defvar ControlGearShiftDomain (loop for i from 0 to 2 collect i))
(defvar GearHandleDomain (loop for i from 0 to 3 collect i))
(defvar GearShiftDomain (loop for i from 0 to 5 collect i))
(defvar ActualGearDomain (loop for i from 0 to 3 collect i))
(defvar TransmissionShaftStateDomain (loop for i from 0 to 1 collect i))

; Variables
(define-variable controlGearShift ControlGearShiftDomain)
(define-variable gearHandle GearHandleDomain)
(define-variable gearShift GearShiftDomain)
(define-variable actualGear ActualGearDomain)
(define-variable transmissionShaftState TransmissionShaftStateDomain)

; Axioms
(defvar Mechanic
	(&&
		(->
			(!! (gearShift-is Nothing))
			(&&
				(-> (gearShift-is ShiftOneUp) (transmissionShaftState-is Attached))
				(-> (gearShift-is ShiftDrive) (transmissionShaftState-is Detached))
				(-> (gearShift-is ShiftPark) (transmissionShaftState-is Detached))
				(-> (gearShift-is ShiftReverse) (transmissionShaftState-is Detached))
			)
		)
		(->
			(transmissionShaftState-is Attached)
			(|| (actualGear-is First) (actualGear-is Second) (actualGear-is Reverse))
		)
	)
)

(defvar PropagateGearShiftCommand
	(->
		(!! (controlGearShift-is Nothing))
		(&&
			(->
				(|| (controlGearShift-is TCUOneUp) (controlGearShift-is TCUOneDown))
				(&&
					(Lasts_ii (gearHandle-is Nothing) FluidPropagationDelay)
					(Lasts_ei (ControlGearShift-is Nothing) FluidPropagationDelay)
				)
			)
			(->
				(controlGearShift-is TCUOneUp)
				(Futr (gearShift-is ShiftOneUp) FluidPropagationDelay)
			)
			(->
				(controlGearShift-is TCUOneDown)
				(Futr (gearShift-is ShiftOneDown) FluidPropagationDelay)
			)
		)
	)
)

(defvar GearHandleCommand
	(->
		(!! (gearHandle-is Nothing))
		(&& 
			(->
				(gearHandle-is HandleDrive)
				(&&
					(Lasts_ii (&& (controlGearShift-is Nothing) (transmissionShaftState-is Detached)) FluidPropagationDelay)
					(Lasts_ei (gearHandle-is Nothing) FluidPropagationDelay)
					(Futr (gearShift-is ShiftDrive) FluidPropagationDelay)
				)
			)
			(->
				(gearHandle-is HandlePark)
				(&&
					(Lasts_ii (&& (controlGearShift-is Nothing) (transmissionShaftState-is Detached)) FluidPropagationDelay)
					(Lasts_ei (gearHandle-is Nothing) FluidPropagationDelay)
					(Futr (gearShift-is ShiftPark) FluidPropagationDelay)
				)
			)
			(->
				(gearHandle-is HandleReverse)
				(&&
					(Lasts_ii (&& (controlGearShift-is Nothing) (transmissionShaftState-is Detached)) FluidPropagationDelay)
					(Lasts_ei (gearHandle-is Nothing) FluidPropagationDelay)
					(Futr (gearShift-is ShiftReverse) FluidPropagationDelay)
				)
			)
		)
	)
)

(defvar GearShiftFirst
	(&&
		(->
			(actualGear-is First)
			(||
				(gearShift-is Nothing)
				(gearShift-is ShiftOneUp)
				(gearShift-is ShiftPark)
				(gearShift-is ShiftReverse)
			)
		)
		(->
			(&& (actualGear-is First) (gearShift-is ShiftOneUp))
			(&&
				(Lasts_ei (gearShift-is Nothing) SingleGearShiftDelay)
				(Futr (actualGear-is Second) SingleGearShiftDelay)
			)
		)
		(->
			(&& (actualGear-is First) (gearShift-is ShiftPark))
			(&&
				(Lasts_ii (transmissionShaftState-is Detached) ParkGearShiftDelay)
				(Lasts_ei (gearShift-is Nothing) ParkGearShiftDelay)
				(Futr (actualGear-is Park) ParkGearShiftDelay)
			)
		)
		(->
			(&& (actualGear-is First) (gearShift-is ShiftReverse))
			(&&
				(Lasts_ii (transmissionShaftState-is Detached) ReverseGearShiftDelay)
				(Lasts_ei (gearShift-is Nothing) ReverseGearShiftDelay)
				(Futr (actualGear-is Reverse) ReverseGearShiftDelay)
			)
		)
	)
)

(defvar GearShiftSecond
	(&&
		(->
			(actualGear-is Second)
			(|| (gearShift-is Nothing) (gearShift-is ShiftOneDown))
		)
		(->
			(&& (actualGear-is Second) (gearShift-is ShiftOneDown))
			(&&
				(Lasts_ei (gearShift-is Nothing) SingleGearShiftDelay)
				(Futr (actualGear-is First) SingleGearShiftDelay)
			)
		)
	)
)

(defvar GearShiftPark
	(&&
		(-> (actualGear-is Park) (transmissionShaftState-is Detached))
		(->
			(actualGear-is Park)
			(||	(gearShift-is Nothing) (gearShift-is ShiftDrive) (gearShift-is ShiftReverse))
		)
		(->
			(&& (actualGear-is Park) (gearShift-is ShiftDrive))
			(&&
				(Lasts_ii (transmissionShaftState-is Detached) DriveGearShiftDelay)
				(Lasts_ei (gearShift-is Nothing) DriveGearShiftDelay)
				(Futr (actualGear-is First) DriveGearShiftDelay)
			)
		)
		(->
			(&& (actualGear-is Park) (gearShift-is ShiftReverse))
			(&&
				(Lasts_ii (transmissionShaftState-is Detached) ReverseGearShiftDelay)
				(Lasts_ei (gearShift-is Nothing) ReverseGearShiftDelay)
				(Futr (actualGear-is Reverse) ReverseGearShiftDelay)
			)
		)
	)
)

(defvar GearShiftReverse
	(&&
		(->
			(actualGear-is Reverse)
			(||	(gearShift-is Nothing) (gearShift-is ShiftDrive) (gearShift-is ShiftPark))
		)
		(->
			(&& (actualGear-is Reverse) (gearShift-is ShiftDrive))
			(&&
				(Lasts_ii (transmissionShaftState-is Detached) DriveGearShiftDelay)
				(Lasts_ei (gearShift-is Nothing) DriveGearShiftDelay)
				(Futr (actualGear-is First) DriveGearShiftDelay)
			)
		)
		(->
			(&& (actualGear-is Reverse) (gearShift-is ShiftPark))
			(&&
				(Lasts_ii (transmissionShaftState-is Detached) ParkGearShiftDelay)
				(Lasts_ei (gearShift-is Nothing) ParkGearShiftDelay)
				(Futr (actualGear-is Park) ParkGearShiftDelay)
			)
		)
	)
)



;actualGear=First & controlGearShift=TCUOneUp & not Futr(actualGear=Second, FluidPropagationDelay+SingleGearShiftDelay);
;actualGear=First & gearHandle=HandleReverse & (not Futr(actualGear=Reverse, FluidPropagationDelay+ReverseGearShiftDelay) | not Lasts(transmissionShaftState=Detached, FluidPropagationDelay+ReverseGearShiftDelay));
;actualGear=First & gearHandle=HandlePark & (not Futr(actualGear=Park, FluidPropagationDelay+ParkGearShiftDelay) | not Since(transmissionShaftState=Detached, controlGearShift<>Nothing | gearHandle<>Nothing));

(defvar CCAT
	(Alw
		(&&
			Mechanic
			PropagateGearShiftCommand
			GearHandleCommand
			GearShiftFirst
			GearShiftSecond
			GearShiftPark
			GearShiftReverse
			
			;;;;;;;;;; PROPERTY 1 ;;;;;;;;;;;;;;
			;(!!(->	(&&(actualGear-is First) (controlGearShift-is TCUOneUp)) 
			;	(Futr(actualGear-is Second) (+ FluidPropagationDelay SingleGearShiftDelay))))
			
			;;;;;;;;;; PROPERTY 2 ;;;;;;;;;;;;;;
			;(!!(-> 	(&& (actualGear-is First) (gearHandle-is HandleReverse))
			;(&& (Futr(actualGear-is Reverse) (+ FluidPropagationDelay ReverseGearShiftDelay)) (Lasts(transmissionShaftState-is Detached) (+ 				;FluidPropagationDelay ReverseGearShiftDelay) )
			;)
			;))

			;;;;;;;;;; PROPERTY 3 ;;;;;;;;;;;;;;
			(!!
			
				(->	(&&(actualGear-is First)(gearHandle-is HandlePark))
					(&&	(Futr(actualGear-is Park) (+ FluidPropagationDelay ParkGearShiftDelay)) 
						(Since(transmissionShaftState-is Detached) (!!(gearHandle-is Nothing)) 
						)
					)			
				)
			
			)
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


		)
	)
)




(bezot:zot 10 CCAT)
