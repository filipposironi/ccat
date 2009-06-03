;CCAT

(asdf:operate 'asdf:load-op 'bezot)
(use-package :trio-utils)


;Constants

(defvar noEvent 0)
(defvar HandleDrive 1)
(defvar HandlePark 2)
(defvar HandleReverse 3)

(defvar TCUOneUp 1)
(defvar TCUOneDown 2)


(defvar ShiftOneUp 1)
(defvar ShiftOneDown 2)
(defvar ShiftDrive 3)
(defvar ShiftPark 4)
(defvar ShiftReverse 5)

(defvar FluidPropagationDelay 1)

(defvar SingleGearShiftDelay 2)
(defvar DriveGearShiftDelay 3)
(defvar ParkGearShiftDelay 3)
(defvar ReverseGearShiftDelay 3)

(defvar First 0)
(defvar Second 1)
(defvar Park 2)
(defvar Reverse 3) 

(defvar GearHandleDomain (loop for i from 0 to 3 collect i))
(defvar ControlGearShiftDomain (loop for i from 0 to 2 collect i))
(defvar GearShiftDomain (loop for i from 0 to 5 collect i))
(defvar ActualGearDomain (loop for i from 0 to 3 collect i))

(define-variable GearHandle GearHandleDomain)
(define-variable ControlGearShift ControlGearShiftDomain)
(define-variable GearShift GearShiftDomain)
(define-variable ActualGear ActualGearDomain)

;Axioms
;HS
	;initial condition
 	(defvar init
  		(ActualGear-is First)
	)



	(defvar GearHandleCommand
	(->	(!!(GearHandle-is noEvent))
    	 	(&& 
			(->	(GearHandle-is HandleDrive)
				(&&
					(Lasts_ii(&&	(ControlGearShift-is noEvent)
							(!!(-P- transmissionShaftState))
						) FluidPropagationDelay)
					(Lasts(GearHandle-is noEvent) FluidPropagationDelay)
					(Futr(GearShift-is ShiftDrive) FluidPropagationDelay)
				)
			)
			(->	(GearHandle-is HandlePark)
				(&&
					(Lasts_ii(&&(ControlGearShift-is noEvent)(!!(-P- transmissionShaftState))) FluidPropagationDelay)
					(Lasts(GearHandle-is noEvent) FluidPropagationDelay)
					(Futr(GearShift-is ShiftPark) FluidPropagationDelay)
				)
			)
			(->	(GearHandle-is HandleReverse)
				(&&
					(Lasts_ii(&&(ControlGearShift-is noEvent)(!!(-P- transmissionShaftState))) FluidPropagationDelay)
					(Lasts(GearHandle-is noEvent) FluidPropagationDelay)
					(Futr(GearShift-is ShiftReverse) FluidPropagationDelay)
				)
			)
		)
	)
	)



	(defvar PropagateGearShiftCommand
	(->	(!!(ControlGearShift-is noEvent))
		(->
			(||	(ControlGearShift-is TCUOneUp)
				(ControlGearShift-is TCUOneDown)
			)
			(&&
				(Lasts_ei(ControlGearShift-is noEvent) FluidPropagationDelay)	
				(Lasts_ii(GearHandle-is noEvent) FluidPropagationDelay)
				(->	(ControlGearShift-is TCUOneUp)
					(Futr(GearShift-is ShiftOneUp) FluidPropagationDelay)
				)
				(->	(ControlGearShift-is TCUOneDown)
					(Futr(GearShift-is ShiftOneDown) FluidPropagationDelay)
				)

			)
		)	
	)
	)


;PGS

	
	(defvar Mechanics
		(->	(!!(GearShift-is noEvent)) 
			(&&	(->(GearShift-is ShiftOneUp)( -P- transmissionShaftState))
				(->(GearShift-is ShiftDrive)(!!( -P- transmissionShaftState)))
			 	(->(GearShift-is ShiftPark) (!!( -P- transmissionShaftState)))
				(->(GearShift-is ShiftReverse) (!!( -P- transmissionShaftState)))
	
				(->( -P- transmissionShaftState) (||(ActualGear-is First) (ActualGear-is Second)(ActualGear-is 									Reverse))
				)
			)
		)
	
	)

	


	(defvar GearShiftFirst
		(&&	(->	(ActualGear-is First)
				(||(GearShift-is noEvent)(GearShift-is ShiftOneUp)(GearShift-is ShiftPark)(GearShift-is ShiftReverse))
			)
			(->	(&&(ActualGear-is First)(GearShift-is ShiftOneUp))
				(&&(Lasts_ei(GearShift-is noEvent) SingleGearShiftDelay)(Futr(ActualGear-is Second)  					SingleGearShiftDelay))
			)
			(->	(&&(ActualGear-is First)(GearShift-is ShiftPark))
				(&&(Lasts_ii(!!(-P- transmissionShaftState) ParkGearShiftDelay))(Lasts_ei(GearShift-is noEvent) ParkGearShiftDelay)(Futr(ActualGear-is Park)  					ParkGearShiftDelay))
			)
			(->	(&&(ActualGear-is First)(GearShift-is ShiftReverse))
				(&&(Lasts_ii(!!(-P- transmissionShaftState) ReverseGearShiftDelay))(Lasts_ei(GearShift-is noEvent) ReverseGearShiftDelay)(Futr(ActualGear-is Reverse)  					ReverseGearShiftDelay))
			)
		)
	)




	(defvar GearShiftSecond
		(&&	(->	(ActualGear-is Second)
				(||(GearShift-is noEvent)(GearShift-is ShiftOneDown))
			)
			(->	(&&(ActualGear-is Second)(GearShift-is ShiftOneDown))
				(&&(Lasts_ei(GearShift-is noEvent) SingleGearShiftDelay)(Futr(ActualGear-is First)  					SingleGearShiftDelay))
			)
		)
	)



	(defvar GearShiftReverse
	(->	(!!(GearShift-is noEvent))
		(&&	(->	(ActualGear-is Reverse)
				(||(GearShift-is noEvent)(GearShift-is ShiftDrive)(GearShift-is ShiftPark))
			)
			(->	(&&(ActualGear-is Reverse)(GearShift-is ShiftDrive))
				(&&	(Lasts_ii(!!(-P- transmissionShaftState)) DriveGearShiftDelay)
					(Lasts_ei(GearShift-is noEvent) DriveGearShiftDelay)
					(Futr(ActualGear-is First) DriveGearShiftDelay)
				)
			)
			(->	(&&(ActualGear-is Reverse)(GearShift-is ShiftPark))
				(&&	(Lasts_ii(!!(-P- transmissionShaftState)) ParkGearShiftDelay)
					(Lasts_ei(GearShift-is noEvent) ParkGearShiftDelay)
					(Futr(ActualGear-is Park) ParkGearShiftDelay)
				)
			)
			
		)
	)
	)


	(defvar GearShiftPark
		(&&	(->	(ActualGear-is Park)
				(!! (-P- transmissionShaftState))
			)
			(->	(ActualGear-is Park)
				(||(GearShift-is noEvent)(GearShift-is ShiftDrive)(GearShift-is ShiftReverse))
			)
			(->	(&&(ActualGear-is Park)(GearShift-is ShiftDrive))
				(&&(Lasts_ii(!!(-P- transmissionShaftState)) DriveGearShiftDelay)(Lasts_ei(GearShift-is noEvent) DriveGearShiftDelay)(Futr(ActualGear-is First)  					DriveGearShiftDelay))
			)
			(->	(&&(ActualGear-is Park)(GearShift-is ShiftReverse))
				(&&(Lasts_ii(!!(-P- transmissionShaftState)) ReverseGearShiftDelay)(Lasts_ei(GearShift-is noEvent) ReverseGearShiftDelay)(Futr(ActualGear-is Reverse)  					ReverseGearShiftDelay))
			)
			
		)
	)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;non funziona
	(defvar prop
	(->	(&&(ActualGear-is First)(gearHandle-is HandleReverse))
			(&&(Futr(ActualGear-is Reverse) (+ FluidPropagationDelay ReverseGearShiftDelay))
			(Lasts(!!(-P- transmissionShaftState)) (+ FluidPropagationDelay ReverseGearShiftDelay)))
		

	)
	)

	;non funziona
	(defvar prop2
		(->	(ActualGear-is Second)
				(Past(ActualGear-is First) (+ FluidPropagationDelay SingleGearShiftDelay))
		)
	) 
	
	; funziona
	(defvar prop3
		(->	(ActualGear-is Park)
				(Past(||(ActualGear-is First)(ActualGear-is Reverse)) FluidPropagationDelay)
		)
		
			
	) 
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;theorem proof
(bezot:zot 10
  
		(&&(yesterday init)(!! prop3))	

	
)




