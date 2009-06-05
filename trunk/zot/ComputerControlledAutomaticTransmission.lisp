(asdf:operate 'asdf:load-op 'bezot)
(use-package :trio-utils)

; Constants
(defvar Nothing 0)

(defvar TCUShiftOneUp 1)
(defvar TCUShiftOneDown 2)

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

(defvar FluidDelay 1)
(defvar ShiftDelay 1)

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
(defvar ControlGearShiftMutualExclusion
	(&&
		(-E- x '(0 1 2) (-P- controlGearShift x))
		(-A- x '(0 1 2)
			(->
				(-P- controlGearShift x)
				(-A- y '(0 1 2) (->	(!! (= x y)) (!! (-P- controlGearShift y))))
			)
		)
	)
)

(defvar GearHandleMutualExclusion
	(&&
		(-E- x '(0 1 2 3) (-P- gearHandle x))
		(-A- x '(0 1 2 3)
			(->
				(-P- gearHandle x)
				(-A- y '(0 1 2 3) (->	(!! (= x y)) (!! (-P- gearHandle y))))
			)
		)
	)
)

(defvar GearShiftMutualExclusion
	(&&
		(-E- x '(0 1 2 3 4 5) (-P- gearShift x))
		(-A- x '(0 1 2 3 4 5)
			(->
				(-P- gearShift x)
				(-A- y '(0 1 2 3 4 5) (->	(!! (= x y)) (!! (-P- gearShift y))))
			)
		)
	)
)

(defvar ActualGearMutualExclusion
	(&&
		(-E- x '(0 1 2 3) (-P- actualGear x))
		(-A- x '(0 1 2 3)
			(->
				(-P- actualGear x)
				(-A- y '(0 1 2 3) (->	(!! (= x y)) (!! (-P- actualGear y))))
			)
		)
	)
)

(defvar TransmissionShaftStateMutualExclusion
	(&&
		(-E- x '(0 1) (-P- transmissionShaftState x))
		(-A- x '(0 1)
			(->
				(-P- transmissionShaftState x)
				(-A- y '(0 1) (->	(!! (= x y)) (!! (-P- transmissionShaftState y))))
			)
		)
	)
)

(defvar Mechanic
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
			(actualGear-is Second)
			(|| (gearShift-is Nothing) (gearShift-is ShiftOneDown))
		)
		(->
			(actualGear-is Park)
			(||	(gearShift-is Nothing) (gearShift-is ShiftDrive) (gearShift-is ShiftReverse))
		)
		(->
			(actualGear-is Reverse)
			(||	(gearShift-is Nothing) (gearShift-is ShiftDrive) (gearShift-is ShiftPark))
		)
		(->	(gearShift-is ShiftOneUp) (transmissionShaftState-is Attached))
		(->
			(||
				(gearShift-is ShiftDrive)
				(gearShift-is ShiftPark)
				(gearShift-is ShiftReverse)
			)
			(transmissionShaftState-is Detached)
		)
		(->
			(transmissionShaftState-is Attached)
			(|| (actualGear-is First) (actualGear-is Second) (actualGear-is Reverse))
		)
		(-> (actualGear-is Park) (transmissionShaftState-is Detached))
		(->
			(&&
				(controlGearShift-is Nothing)
				(gearHandle-is Nothing)
			)
			(Futr (gearShift-is Nothing) FluidDelay)
		)
		(-A- x '(0 1 2 3)
			(->
				(&& (-P- actualGear x) (gearShift-is Nothing))
				(Lasts_ii (-P- actualGear x) ShiftDelay)
			)
		)
	)
)

(defvar GearShiftCommand
	(&&
		(->
			(controlGearShift-is TCUShiftOneUp)
			(Futr (gearShift-is ShiftOneUp) FluidDelay)
		)
		(->
			(controlGearShift-is TCUShiftOneDown)
			(Futr (gearShift-is ShiftOneDown) FluidDelay)
		)
	)
)

(defvar GearHandleCommand
	(&& 
		(->
			(gearHandle-is HandleDrive)
			(&&
				(Lasts_ii (&& (controlGearShift-is Nothing) (transmissionShaftState-is Detached)) FluidDelay)
				(Lasts_ei (gearHandle-is Nothing) FluidDelay)
				(Futr (gearShift-is ShiftDrive) FluidDelay)
			)
		)
		(->
			(gearHandle-is HandlePark)
			(&&
				(Lasts_ii (&& (controlGearShift-is Nothing) (transmissionShaftState-is Detached)) FluidDelay)
				(Lasts_ei (gearHandle-is Nothing) FluidDelay)
				(Futr (gearShift-is ShiftPark) FluidDelay)
			)
		)
		(->
			(gearHandle-is HandleReverse)
			(&&
				(Lasts_ii (&& (controlGearShift-is Nothing) (transmissionShaftState-is Detached)) FluidDelay)
				(Lasts_ei (gearHandle-is Nothing) FluidDelay)
				(Futr (gearShift-is ShiftReverse) FluidDelay)
			)
		)
	)
)

(defvar GearShiftFirst
	(&&
		(->
			(&& (actualGear-is First) (gearShift-is ShiftOneUp))
			(&&
				(Lasts_ei (gearShift-is Nothing) ShiftDelay)
				(Futr (actualGear-is Second) ShiftDelay)
			)
		)
		(->
			(&& (actualGear-is First) (gearShift-is ShiftPark))
			(&&
				(Lasts_ii (transmissionShaftState-is Detached) ShiftDelay)
				(Lasts_ei (gearShift-is Nothing) ShiftDelay)
				(Futr (actualGear-is Park) ShiftDelay)
			)
		)
		(->
			(&& (actualGear-is First) (gearShift-is ShiftReverse))
			(&&
				(Lasts_ii (transmissionShaftState-is Detached) ShiftDelay)
				(Lasts_ei (gearShift-is Nothing) ShiftDelay)
				(Futr (actualGear-is Reverse) ShiftDelay)
			)
		)
	)
)

(defvar GearShiftSecond
	(->
		(&& (actualGear-is Second) (gearShift-is ShiftOneDown))
		(&&
			(Lasts_ei (gearShift-is Nothing) ShiftDelay)
			(Futr (actualGear-is First) ShiftDelay)
		)
	)
)

(defvar GearShiftPark
	(&&
		(->
			(&& (actualGear-is Park) (gearShift-is ShiftDrive))
			(&&
				(Lasts_ii (transmissionShaftState-is Detached) ShiftDelay)
				(Lasts_ei (gearShift-is Nothing) ShiftDelay)
				(Futr (actualGear-is First) ShiftDelay)
			)
		)
		(->
			(&& (actualGear-is Park) (gearShift-is ShiftReverse))
			(&&
				(Lasts_ii (transmissionShaftState-is Detached) ShiftDelay)
				(Lasts_ei (gearShift-is Nothing) ShiftDelay)
				(Futr (actualGear-is Reverse) ShiftDelay)
			)
		)
	)
)

(defvar GearShiftReverse
	(&&
		(->
			(&& (actualGear-is Reverse) (gearShift-is ShiftDrive))
			(&&
				(Lasts_ii (transmissionShaftState-is Detached) ShiftDelay)
				(Lasts_ei (gearShift-is Nothing) ShiftDelay)
				(Futr (actualGear-is First) ShiftDelay)
			)
		)
		(->
			(&& (actualGear-is Reverse) (gearShift-is ShiftPark))
			(&&
				(Lasts_ii (transmissionShaftState-is Detached) ShiftDelay)
				(Lasts_ei (gearShift-is Nothing) ShiftDelay)
				(Futr (actualGear-is Park) ShiftDelay)
			)
		)
	)
)

(defvar ComputerControlledAutomaticTransmission
	(Alw
		(&&
			ControlGearShiftMutualExclusion
			GearHandleMutualExclusion
			GearShiftMutualExclusion
			ActualGearMutualExclusion
			TransmissionShaftStateMutualExclusion
			Mechanic
			GearShiftCommand
			GearHandleCommand
			GearShiftFirst
			GearShiftSecond
			GearShiftPark
			GearShiftReverse
		)
	)
)

(defvar PropertyOne
	(->
		(&& (actualGear-is First) (controlGearShift-is TCUShiftOneUp)) 
		(Futr (actualGear-is Second) (+ FluidDelay ShiftDelay))
	)
)

(defvar PropertyTwo
	(->
		(&& (actualGear-is First) (gearHandle-is HandleReverse))
		(&&
			(Futr (actualGear-is Reverse) (+ FluidDelay ShiftDelay))
			(Lasts_ii (transmissionShaftState-is Detached) (+ FluidDelay ShiftDelay))
		)
	)
)

(defvar PropertyThree
	(->
		(&& (actualGear-is First) (gearHandle-is HandlePark))
		(&&
			(Futr (actualGear-is Park) (+ FluidDelay ShiftDelay)) 
			(Until (transmissionShaftState-is Detached) (!! (gearHandle-is Nothing)))
		)
	)			
)

(bezot:zot 20 ComputerControlledAutomaticTransmission)
;(bezot:zot 20 (&& ComputerControlledAutomaticTransmission (!! (Alw PropertyOne))))
;(bezot:zot 20 (&& ComputerControlledAutomaticTransmission (!! (Alw PropertyTwo))))
;(bezot:zot 20 (&& ComputerControlledAutomaticTransmission (!! (Alw PropertyThree))))
