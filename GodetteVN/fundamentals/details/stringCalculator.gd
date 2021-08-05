extends Node
class_name stringCalculator

# converts evaluates string of arithmetic expression

const p = ["(", ")"]
const prec = {"(":0 , "+":1, "-": 1, "*":2, "/":2, "^":3}
const operators = ["+", "-", "*", "^", "/", "("]
const bool_prec = {"==":1, ">=":1, "<=":1, "<":1, ">":1, 'and': 0, 'or': 0}
const bool_operators = ["==",'>=','<=','!=','<','>', 'and', 'or']
const left = "("
const right = ")"


func calculate(expression:String):
	var postfix = _infix_postfix(expression)
	return _eval_a(postfix)


func _paren_check(st : String) -> bool:
	var stack = []
	for s in st:
		if s == left:
			stack.push_back(s)
			
		if s == right:
			var t = stack.pop_back()
			if t != left:
				return false
	
	if stack.size() == 0:
		return true
	else:
		return false
		
func _format_expression(ex):
	var output = []
	for e in ex:
		if e.is_valid_float() or vn.dvar.has(e):
			output.push_back(e)
		else: 
			# not number
			e = e.replace(" ", "") # remove all whitespace
			for a in e:
				output.push_back(a)

	return output

func _infix_postfix(ex:String):
	if _paren_check(ex):
		var regexMatch = "(\\d+\\.?\\d*)|(\\+)|(-)|(\\*)|(\\^)|(\\()|(\\))|(/)"
		for v in vn.dvar.keys():
			# Will be terribly slow if you have way too many dvars
			# Also this will bug if there is a dvar called (a or something like that...
			# Have to trust the user 
			if v in ex:
				regexMatch += "|("+v+")"
				
		var regex = RegEx.new()
		regex.compile(regexMatch)
		var results = []
		for result in regex.search_all(ex):
			results.push_back(result.get_string())
		
		results = _format_expression(results)
		var output = []
		var stack = []
		for le in results:
			if le.is_valid_float() or vn.dvar.has(le):
				output.push_back(le)
			elif le == left:
				stack.push_back(le)
			elif le == right:
				var top = stack.pop_back()
				while top != left:
					output.push_back(top)
					top = stack.pop_back()
					
			elif le in operators:
				while (stack.size()!=0) and prec[stack[stack.size()-1]]>=prec[le]:
					output.push_back(stack.pop_back())
					
				stack.push_back(le)
				
		while stack.size() > 0:
			output.push_back(stack.pop_back())
			
		return output
		
	else:
		vn.error("Check your parenthesis.")
		
func _eval_a(ex_arr) -> float:
	
	var stack = []
	for e in ex_arr:
		if e.is_valid_float():
			stack.push_back(float(e))
		elif vn.dvar.has(e):
			if typeof(vn.dvar[e]) == 3 or typeof(vn.dvar[e]) == 2: 
				# 3 = real numbers, 2 = integers
				stack.push_back(vn.dvar[e])
			else:
				vn.error("The type of dvar {0} is not float. Cannot evaluate.".format({0:e}))
		else:
			var second = stack.pop_back()
			var first = stack.pop_back()
			if e == "+":
				stack.push_back(first+second)
				#print("Doing {0}+{1}".format({0:first,1:second}))
			elif e == "-":
				stack.push_back(first-second)
				#print("Doing {0}-{1}".format({0:first,1:second}))
			elif e == "*":
				stack.push_back(first*second)
				#print("Doing {0}*{1}".format({0:first,1:second}))
			elif e == "^":
				stack.push_back(pow(first,second))
				#print("Doing {0}^{1}".format({0:first,1:second}))
			elif e == "/":
				stack.push_back(first/second)
				#print("Doing {0}/{1}".format({0:first,1:second}))
			else:
				vn.error("Unrecognized operator " + e)
		
		
	return stack.pop_back()
