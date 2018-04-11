#pragma once
#include <vector>
#include <string>
#include <any>
#include <unordered_map>
#include <functional>

#include "ParserTypes.h"


//In Runner.h
class Runner;
class FunctionDefinition;

struct BuiltinFunction {
	std::variant<std::function<void(Runner*)>, std::function<void(Runner*, FunctionDefinition*)>> f;
	bool takesContext;
};

class PredefinedFunctions {
private:
	//helper function to ensure the function is 2 things:
	//a) a number
	//b) an int
	static bool isInt(CharmFunction f);
public:
	std::unordered_map<std::string, BuiltinFunction> cppFunctionNames;
	PredefinedFunctions();
	void functionLookup(std::string functionName, Runner* r, FunctionDefinition* context);
	void addBuiltinFunction(std::string n, std::function<void(Runner*, FunctionDefinition*)> f);
	void addBuiltinFunction(std::string n, std::function<void(Runner*)> f);
	//INPUT / OUTPUT
	static inline void print(CharmFunction f1);
	static inline void p(Runner* r);
	static inline void newline(Runner* r);
	static inline void getline(Runner* r);
	//STACK MANIPULATIONS
	static inline void dup(Runner* r);
	static inline void pop(Runner* r);
	static inline void swap(Runner* r);
	//LIST / STRING MANIPULATIONS
	static inline void len(Runner* r);
	static inline void at(Runner* r);
	static inline void insert(Runner* r);
	static inline void concat(Runner* r);
	static inline void split(Runner* r);
	static inline void toString(Runner* r);
	//CONTROL FLOW
	static inline void i(Runner* r);
	static inline void q(Runner* r);
	static inline void ifthen(Runner* r, FunctionDefinition* context);
	//BOOLEAN OPS
	static inline void exor(Runner* r);
	//TYPE INSPECIFIC MATH
	static inline void abs(Runner* r);
	//INTEGER OPS
	static inline void plusI(Runner* r);
	static inline void minusI(Runner* r);
	static inline void divI(Runner* r);
	static inline void timesI(Runner* r);
	static inline void toInt(Runner* r);
	//STACK CREATION/DESTRUCTION
	static inline void createStack(Runner* r);
	static inline void switchStack(Runner* r);
	//REF GETTING/SETTING
	static inline void getRef(Runner* r);
	static inline void setRef(Runner* r);
};
