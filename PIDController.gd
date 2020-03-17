extends Node

var kP : float = -0.7
var kI : float = -0.01
var kD : float = -0.3
var minIntegral = null
var minCapIntegral = null
var error = 0
var previousError = 0
var integralError = 0
var derivativeError = 0
var maxCapIntegral = null
var maxIntegral = null
var retError : float = 0

func _ready():
	pass # Replace with function body.

func _init(var p, var i, var d, var minI, var maxI, var minCapI, var maxCapI):
	kP = p
	kI = i
	kD = d
	minCapIntegral = minCapI
	minIntegral = minI
	maxCapIntegral = maxCapI
	maxIntegral = maxI

func step():
	if previousError == null:
		previousError = error
	
	derivativeError = error - previousError
	integralError = integralError + error
	
	if minCapIntegral != null && minCapIntegral != null && integralError < minCapIntegral:
		integralError = minCapIntegral
	if maxCapIntegral != null && maxCapIntegral != null && integralError > maxCapIntegral:
		integralError = maxCapIntegral

	var mP = error * kP
	var mI = integralError * kI
	var mD = derivativeError * kD

	if minIntegral != null && minIntegral != null && mI < minIntegral:
		mI = minIntegral

	if maxIntegral != null && maxIntegral != null && mI > maxIntegral:
		mI = maxIntegral

	previousError = error
	retError = mP + mI + mD
	return retError

func getError():
	return retError
	
func setError(err: float):
	error = err

func reset():
	integralError = 0

func update(current: float, target: float):
	setError(target - current)
