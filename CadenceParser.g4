parser grammar CadenceParser;

options {
	tokenVocab = CadenceLexer;
}

top_level: statements? EOF;

////////////////////////////////////////////
// Misc
////////////////////////////////////////////
// Generic Parameter Clause
generic_parameter_clause: LT generic_parameter_list GT;
generic_parameter_list: generic_parameter (COMMA generic_parameter)*;
generic_parameter: type_name ( COLON type )?;
// Generic Argument Clause
generic_argument_clause: LT generic_argument_list GT;
generic_argument_list:
	generic_argument (COMMA generic_argument)*;
generic_argument: type;
// Parameter Clause
parameter_clause: LPAREN parameter_list? RPAREN;
parameter_list: parameter (COMMA parameter)*;
parameter: type_name ( COLON type )?;

negate_prefix_operator: SUB;

////////////////////////////////////////////
// Literal
////////////////////////////////////////////
literal:
	numeric_literal
	| string_literal
	| boolean_literal
	| nil_literal;
numeric_literal:
	negate_prefix_operator? integer_literal
	| negate_prefix_operator? Floating_point_literal;
boolean_literal: TRUE | FALSE;
nil_literal: NIL;
integer_literal:
	Decimal_digits
	| Decimal_literal
	| Binary_literal
	| Octal_literal
	| Hexadecimal_literal;
string_literal:
	extended_string_literal
	| interpolated_string_literal
	| static_string_literal;

extended_string_literal:
	Multi_line_extended_string_open Quoted_multi_line_extended_text+
		Multi_line_extended_string_close
	| Single_line_extended_string_open Quoted_single_line_extended_text+
		Single_line_extended_string_close;
static_string_literal:
	Single_line_string_open Quoted_single_line_text* Single_line_string_close
	| Multi_line_string_open Quoted_multi_line_text* Multi_line_string_close;
interpolated_string_literal:
	Single_line_string_open (
		Quoted_single_line_text
		| Interpolataion_single_line (
			expression
			// | tuple_element COMMA tuple_element_list
		) RPAREN
	)* Single_line_string_close
	| Multi_line_string_open (
		Quoted_multi_line_text
		| Interpolataion_multi_line (
			expression
			// | tuple_element COMMA tuple_element_list
		) RPAREN
	)* Multi_line_string_close;
////////////////////////////////////////////
// Expression
////////////////////////////////////////////
expression: prefix_expression 
// binary_expressions?
;

expression_list: expression (COMMA expression)*;

// Prefix Expressions
prefix_expression: prefix_operator? postfix_expression ;

postfix_expression:
	primary_expression
	// (
	// 	function_call_suffix
	// 	| initializer_suffix
	// 	| explicit_member_suffix
	// 	| postfix_self_suffix
	// 	| subscript_suffix
	// 	| forced_value_suffix
	// 	| optional_chaining_suffix
	// )* postfix_operator*?
	;

// // Try Operator
// try_operator: TRY (QUESTION | BANG)?;

// Binary Expressions
// binary_expression:
// 	binary_operator prefix_expression
// 	| (assignment_operator | conditional_operator) try_operator? prefix_expression
// 	| type_casting_operator;

// binary_expressions: binary_expression+;

// Conditional Operator
// conditional_operator: QUESTION expression COLON;

// Ternary Conditional Operator
// type_casting_operator: (IS | AS ( QUESTION | BANG)?) type;

// Primary Expressions
primary_expression:
	// unqualified_name generic_argument_clause?
	// | 
	array_type
	| dictionary_type
	| literal_expression
	| self_expression
	// | superclass_expression
	// | closure_expression
	// | parenthesized_operator
	// | parenthesized_expression
	// | tuple_expression
	// | implicit_member_expression
	// | wildcard_expression
	// | key_path_expression
	// | selector_expression
	// | key_path_string_expression
	;

// unqualified_name: identifier (LPAREN argument_names RPAREN)?;

// Self Expression
self_expression:
	SELF DOT identifier
	// | SELF LBRACK function_call_argument_list RBRACK
	// | SELF DOT INIT
	;

// // Superclass Expression
// superclass_expression:
// 	SUPER DOT identifier								# superclass_method_expression
// 	| SUPER LBRACK function_call_argument_list RBRACK	# superclass_subscript_expression
// 	| SUPER DOT INIT									# superclass_initializer_expression;
// Literal Expression
literal_expression:
	literal
	| array_literal
	| dictionary_literal;
// Array Literal
array_literal: LBRACK array_literal_items? RBRACK;
array_literal_items:
	array_literal_item (COMMA array_literal_item)* COMMA?;
array_literal_item: expression;
// Dictinary Literal
dictionary_literal:
	LBRACK (dictionary_literal_items | COLON) RBRACK;
dictionary_literal_items:
	dictionary_literal_item (COMMA dictionary_literal_item)* COMMA?;
dictionary_literal_item: expression COLON expression;

////////////////////////////////////////////
// Operator
////////////////////////////////////////////
assignment_operator: (EQUAL | MOVE | FORCE_MOVE | SWAP);
compilation_condition_AND: AND AND;
compilation_condition_OR: OR OR;
compilation_condition_GE: GT EQUAL;
compilation_condition_L:  LT;
arrow_operator:  SUB GT;
range_operator:  DOT DOT DOT;
same_type_equals: EQUAL EQUAL;
binary_operator:  operator;
prefix_operator:  operator;
postfix_operator:  operator;
operator:
	operator_head operator_characters?
	| dot_operator_head dot_operator_characters;
operator_head: (
		DIV
		| EQUAL
		| SUB
		| ADD
		| BANG
		| MUL
		| MOD
		| AND
		| OR
		| LT
		| GT
		| CARET
		| TILDE
		| QUESTION
	) // wrapping in (..) makes it a fast set comparison
	| Operator_head_other;
operator_character:
	operator_head
	| Operator_following_character;
operator_characters: (
		{_input.get(_input.index()-1).getType()!=WS}? operator_character
	)+;
dot_operator_head: DOT;
dot_operator_character: DOT | operator_character;
dot_operator_characters: (
		{_input.get(_input.index()-1).getType()!=WS}? dot_operator_character
	)+;
////////////////////////////////////////////
// Declarations
////////////////////////////////////////////
declaration:
	contract_declaration
		// import_declaration
		| constant_declaration
		// | variable_declaration
		// | typealias_declaration
		| function_declaration
		// | enum_declaration
		// | struct_declaration
		// | class_declaration
		// | protocol_declaration
		| initializer_declaration
		// | deinitializer_declaration
		// | extension_declaration
		// | subscript_declaration
		// | operator_declaration
		// | precedence_group_declaration
	;

// Contract Declaratioin
contract_declaration:
	access_level_modifier CONTRACT identifier code_block;
// contract_name: identifier;
// Constant Declaration
constant_declaration:
	declaration_modifiers? LET pattern_initializer_list;
// Function Declaration
function_declaration:
	function_head function_name generic_parameter_clause?
	function_signature
		function_body?;
// Variable Declaration
variable_declaration:
	variable_declaration_head (
		variable_name (COLON type)?
	);
variable_declaration_head: access_level_modifier ( LET | VAR );

// Declaration Modifiers
declaration_modifier:
	// CLASS
	// | CONVENIENCE
	// | DYNAMIC
	// | FINAL
	// | INFIX
	// | LAZY
	// | OPTIONAL
	// | OVERRIDE
	// | POSTFIX
	// | PREFIX
	// | REQUIRED
	// | STATIC
	// | UNOWNED (LPAREN (SAFE | UNSAFE) RPAREN)?
	// | WEAK
	// | 
	access_level_modifier;
	// | mutation_modifier;

declaration_modifiers: declaration_modifier+;
declarations: declaration+;

// Code Blocks
code_block: LCURLY statements? RCURLY;

////////////////////////////////////////////
// Function
////////////////////////////////////////////
function_head: declaration_modifiers? FUNC;
function_name: identifier | operator;
function_signature:
	parameter_clause
	// (THROWS? | RETHROWS)
	function_result?;
function_result: type_annotation;
function_body: code_block;
function_type_argument_clause: LPAREN (function_type_argument_list range_operator?)? RPAREN;
function_type_argument_list: function_type_argument (COMMA function_type_argument)*;
function_type_argument:
	// INOUT?
	type
	| argument_label type_annotation;
argument_label:
	identifier+; // TODO Understand a specific thing - _

////////////////////////////////////////////
// Modifier
////////////////////////////////////////////
access_level_modifier:
	(ACCESS | PRIVATE | PUBLIC ) (
		LPAREN SET RPAREN
	)?;


////////////////////////////////////////////
// Statement
////////////////////////////////////////////
statement:
	(
		declaration
		// | loop_statement
		| assignment_statement
		// | branch_statement
		// | labeled_statement
		| control_transfer_statement
		// // | do_statement
		| expression
	) SEMI?;

statements: statement+;

assignment_statement: 
	(variable | variable_declaration)
	assignment_operator
	(variable | literal_expression);
// Control Transfer Statements
control_transfer_statement:
	break_statement
	| continue_statement
	// | fallthrough_statement
	| return_statement
	// | throw_statement
	;

////////////////////////////////////////////
// Variable
////////////////////////////////////////////
variable: (resource_variable | local_variable);
resource_variable: self_expression;
local_variable: variable_name;
variable_name: identifier;

////////////////////////////////////////////
// Identifier
////////////////////////////////////////////
identifier:
	(
		FILE
		| LINE
		| GET
		| SET
		| IN
		| FOR
		| DEFAULT
		| PRIVATE
		| PUBLIC
		| AS
		| WHILE
		| SELF
		| SET
	)
	| Identifier
	;

////////////////////////////////////////////
// Pattern
////////////////////////////////////////////
//The following sets of rules are mutually left-recursive [pattern, Type-Casting], to avoid this they were integrated into the same rule.
pattern:
	(wildcard_pattern | identifier_pattern | tuple_pattern) type_annotation?
	// | value_binding_pattern
	// | enum_case_pattern
	// | optional_pattern
	// | IS type
	// | pattern AS type
	// | expression_pattern
	;

// Wildcard Pattern
wildcard_pattern: UNDERSCORE;
// identifier Pattern
identifier_pattern: identifier;
// Tuple Pattern
tuple_pattern: LPAREN tuple_pattern_element_list? RPAREN;
tuple_pattern_element_list:
	tuple_pattern_element (COMMA tuple_pattern_element)*;
tuple_pattern_element: (identifier COLON)? pattern;

pattern_initializer_list:
	pattern_initializer (COMMA pattern_initializer)*;
pattern_initializer: pattern initializer?;
initializer: EQUAL expression;

////////////////////////////////////////////
// Type
////////////////////////////////////////////
type:
	function_type
	| array_type
	| dictionary_type
	// | protocol_composition_type
	| type_identifier
	// | tuple_type
	// | opaque_type
	// | type 
	//metatype_type
	| any_type
	// | self_type
	| LPAREN type RPAREN;

// Function Type
function_type:
	function_type_argument_clause 
	// THROWS? 
	arrow_operator type;
// Array Type
array_type: LBRACK type RBRACK;
// Dictionary Type
dictionary_type: LBRACK type COLON type RBRACK;
// Type Annotation
type_annotation: COLON type;
// Type identifier
type_identifier:
	type_name generic_argument_clause? (DOT type_identifier)?;
type_name: (STRING_TYPE | identifier);
// Any Type
any_type: ANY;

////////////////////////////////////////////
// un checked
////////////////////////////////////////////

// // Loop Statements
// loop_statement:
// 	for_in_statement
// 	| while_statement
// 	// | repeat_while_statement
// 	;

// // For-In Statement
// for_in_statement:
// 	FOR CASE? pattern IN expression
// 	// where_clause?
// 	code_block;

// // While Statement
// while_statement: WHILE condition_list code_block;

// condition_list: condition (COMMA condition)*;

// condition:
//   expression
// 	| case_condition
// 	| optional_binding_condition;

// case_condition: CASE pattern initializer;

// optional_binding_condition: (LET | VAR) pattern initializer;

// // // Repeat-While Statement
// // repeat_while_statement: REPEAT code_block WHILE expression;

// // Branch Statements
// branch_statement:
// 	if_statement;
// 	// | guard_statement
// 	// | switch_statement;

// // If Statement
// if_statement: IF condition_list code_block else_clause?;
// else_clause: ELSE code_block | ELSE if_statement;

// // // Guard Statement
// // guard_statement: GUARD condition_list ELSE code_block;

// // Switch Statement
// // switch_statement: SWITCH expression LCURLY switch_cases? RCURLY;
// // switch_cases: switch_case switch_cases?;
// // switch_case: (case_label | default_label) statements;
// // case_label: CASE case_item_list COLON;
// // case_item_list:
// // 	pattern where_clause? (COMMA pattern where_clause?)*;
// default_label: DEFAULT COLON;
// // where_clause: WHERE where_expression;
// where_expression: expression;

// // Labeled Statement
// labeled_statement:
// 	statement_label (
// 		loop_statement
// 		| if_statement
// 		// | switch_statement
// 		// | do_statement
// 	);

// statement_label: label_name COLON;
label_name: identifier;


// Break Statement
break_statement: BREAK label_name?;

// Continue Statement
continue_statement: CONTINUE label_name?;

// // Fallthrough Statement
// fallthrough_statement: FALLTHROUGH;

// Return Statement
return_statement: RETURN expression?;

// Throw Statement
throw_statement: THROW expression;

// // Do Statement
// // do_statement: DO code_block catch_clauses?;
// // catch_clauses: catch_clause+;
// // catch_clause: CATCH catch_pattern_list? code_block;
// // catch_pattern_list:
// // 	catch_pattern (catch_pattern COMMA catch_pattern)*;
// // catch_pattern: pattern where_clause?;

// module_name: identifier (DOT identifier)*;
// // environment: SIMULATOR | MAC_CATALYST;

// // // Line Control Statement
// // line_control_statement:
// // 	SOURCE_LOCATION LPAREN (
// // 		FILE COLON file_name COMMA LINE COLON line_number
// // 	)? RPAREN;

// line_number:
// 	Decimal_literal; // TODO: A decimal integer greater than zero
// file_name: static_string_literal;

// // Compile-Time Diagnostic Statement
// diagnostic_statement: (ERROR | WARNING) LPAREN diagnostic_message RPAREN;

// diagnostic_message: static_string_literal;

// platform_version:
// 	Decimal_literal
// 	| Decimal_digits
// 	| Floating_point_literal (DOT Decimal_digits)?;

// requirement_list: requirement (COMMA requirement)*;
// requirement: conformance_requirement | same_type_requirement;

// conformance_requirement:
// 	type_identifier COLON (
// 		type_identifier
// 		| protocol_composition_type
// 	);
// same_type_requirement:
// 	type_identifier same_type_equals (type_identifier | type);

// // Top-Level Code
// top_level_declaration: statements?;



// // Import Declaration
// import_declaration: IMPORT import_kind? import_path;
// import_kind:
// 	// | TYPEALIAS
// 	STRUCT
// 	// | CLASS
// 	| ENUM
// 	// | PROTOCOL
// 	| LET
// 	| VAR
// 	| FUNC;
// import_path:
// 	import_path_identifier (DOT import_path_identifier)*;
// import_path_identifier: identifier | operator;

// Initializer Declaration
initializer_declaration:
	initializer_head generic_parameter_clause? parameter_clause 
	// (
		// THROWS
		// | RETHROWS
	// )?
	initializer_body;
initializer_head: INIT;
initializer_body: code_block;

// // getter_setter_block:
// // 	LCURLY (
// // 		getter_clause setter_clause?
// // 		| setter_clause getter_clause
// // 	) RCURLY
// // 	| code_block;
// // getter_clause: mutation_modifier? GET code_block?;
// // setter_clause:
// // 	mutation_modifier? SET setter_name? code_block?;
// // setter_name: LPAREN identifier RPAREN;

// // getter_setter_keyword_block:
// // 	LCURLY (
// // 		getter_keyword_clause setter_keyword_clause?
// // 		| setter_keyword_clause getter_keyword_clause
// // 	) RCURLY;
// // getter_keyword_clause: mutation_modifier? GET;
// // setter_keyword_clause: mutation_modifier? SET;

// // willSet_didSet_block:
// // 	LCURLY (
// 		// willSet_clause didSet_clause?
// 		// | didSet_clause willSet_clause?
// 	// ) RCURLY;
// // willSet_clause: WILL_SET setter_name? code_block;
// // didSet_clause: DID_SET setter_name? code_block;

// // Type Alias Declaration
// typealias_declaration:
// 	access_level_modifier?
// 	// TYPEALIAS
// 	typealias_name generic_parameter_clause?
// 		typealias_assignment;
// typealias_name: identifier;
// typealias_assignment: EQUAL type;

// // Enumeration Declaration
// enum_declaration:
// 	access_level_modifier? (
// 		union_style_enum
// 		| raw_value_style_enum
// 	);

// union_style_enum:
// 	// INDIRECT?
// 	ENUM enum_name generic_parameter_clause? type_inheritance_clause?
// 		LCURLY union_style_enum_members? RCURLY;

// union_style_enum_members: union_style_enum_member+;

// union_style_enum_member:
// 	declaration
// 	| union_style_enum_case_clause;

// union_style_enum_case_clause:
// 	// INDIRECT?
// 	CASE union_style_enum_case_list;

// union_style_enum_case_list:
// 	union_style_enum_case (COMMA union_style_enum_case)*;

// union_style_enum_case:
// 	// opaque_type |
// 	enum_case_name (tuple_type | LPAREN type RPAREN)?;

// enum_name: identifier;

// enum_case_name: identifier;

// raw_value_style_enum:
// 	ENUM enum_name generic_parameter_clause? type_inheritance_clause LCURLY
// 		raw_value_style_enum_members RCURLY;

// raw_value_style_enum_members: raw_value_style_enum_member+;

// raw_value_style_enum_member:
// 	declaration
// 	| raw_value_style_enum_case_clause;

// raw_value_style_enum_case_clause:
// 	CASE raw_value_style_enum_case_list;

// raw_value_style_enum_case_list:
// 	raw_value_style_enum_case (COMMA raw_value_style_enum_case)*;

// raw_value_style_enum_case: enum_case_name raw_value_assignment?;

// raw_value_assignment: EQUAL raw_value_literal;

// raw_value_literal:
// 	numeric_literal
// 	| static_string_literal
// 	| boolean_literal;

// // Structure Declaration
// struct_declaration:
// 	access_level_modifier? STRUCT struct_name generic_parameter_clause?
// 		type_inheritance_clause? struct_body;
// struct_name: identifier;
// struct_body: LCURLY struct_members RCURLY;
// struct_members: struct_member*;
// struct_member: declaration ;

// // Class Declaration
// class_declaration:
// 	(
// 		access_level_modifier?
// 		// FINAL?
// 		// |
// 		// FINAL
// 		access_level_modifier?
// 	) 
// 	// CLASS
// 	class_name generic_parameter_clause? type_inheritance_clause?
// 		class_body;
// class_name: identifier;
// class_body: LCURLY class_members RCURLY;
// class_members: class_member*;
// class_member: declaration ;

// // // Protocol Declaration
// // protocol_declaration:
// // 	access_level_modifier?
// // 	// PROTOCOL
// // 	protocol_name (
// // 		COLON
// // 		// CLASS
// // 		| type_inheritance_clause
// // 	)? protocol_body;
// // protocol_name: identifier;
// // protocol_body: LCURLY protocol_members RCURLY;
// // protocol_members: protocol_member*;

// // protocol_member:
// // 	protocol_member_declaration;

// // protocol_member_declaration:
// // 	protocol_property_declaration
// // 	| protocol_method_declaration
// // 	| protocol_initializer_declaration
// // 	| protocol_subscript_declaration
// // 	| protocol_associated_type_declaration
// // 	| typealias_declaration;

// // // Protocol Property Declaration
// // protocol_property_declaration:
// // 	variable_declaration_head variable_name type_annotation getter_setter_keyword_block;

// // // Protocol Method Declaration
// // protocol_method_declaration:
// // 	function_head function_name generic_parameter_clause? function_signature;

// // // Protocol Initializer Declaration
// // protocol_initializer_declaration:
// // 	initializer_head generic_parameter_clause? parameter_clause (
// // 		THROWS?
// // 		| RETHROWS
// // 	);

// // // Protocol Subscript Declaration
// // protocol_subscript_declaration:
// // 	subscript_head subscript_result getter_setter_keyword_block;

// // // Protocol Associated Type Declaration
// // protocol_associated_type_declaration:
// // 	access_level_modifier? ASSOCIATED_TYPE typealias_name type_inheritance_clause?
// // 		typealias_assignment?;


// // Deinitializer Declaration
// // deinitializer_declaration: DEINIT code_block;

// // Extension Declaration
// // extension_declaration:
// // 	access_level_modifier? EXTENSION type_identifier type_inheritance_clause?
// // 	 extension_body;
// // extension_body: LCURLY extension_members RCURLY;
// // extension_members: extension_member*;
// // extension_member: declaration ;

// // Subscript Declaration
// // subscript_declaration:
// // 	subscript_head subscript_result (
// // 		code_block
// // 		| getter_setter_block
// // 		| getter_setter_keyword_block
// // 	);

// // subscript_head:
// // 	declaration_modifiers? SUBSCRIPT generic_parameter_clause? parameter_clause;
// // subscript_result: arrow_operator type;

// // Operator Declaration
// // operator_declaration:
// // 	prefix_operator_declaration
// // 	| postfix_operator_declaration
// // 	| infix_operator_declaration;

// // prefix_operator_declaration: PREFIX OPERATOR operator;
// // postfix_operator_declaration: POSTFIX OPERATOR operator;
// // infix_operator_declaration:
// // 	INFIX OPERATOR operator infix_operator_group?;

// // infix_operator_group: COLON precedence_group_name;

// // // Precedence Group Declaration
// // precedence_group_declaration:
// // 	PRECEDENCE_GROUP precedence_group_name LCURLY RCURLY;
// // precedence_group_attributes: precedence_group_attribute+;

// // precedence_group_attribute:
// // 	precedence_group_relation
// // 	| precedence_group_assignment
// // 	| precedence_group_associativity;

// // precedence_group_relation:
// // 	(HIGHER_THAN | LOWER_THAN) COLON precedence_group_names;

// // precedence_group_assignment: ASSIGNMENT COLON boolean_literal;

// // precedence_group_associativity:
// // 	ASSOCIATIVITY COLON (LEFT | RIGHT | NONE);

// // precedence_group_names:
// // 	precedence_group_name (COMMA precedence_group_name)*;
// // precedence_group_name: identifier (DOT identifier)*;


// // mutation_modifier: MUTATING | NONMUTATING;

// // Patterns



// // Value-Binding Pattern
// value_binding_pattern: VAR pattern | LET pattern;

// // Enumeration Case Pattern
// enum_case_pattern:
// 	type_identifier? DOT enum_case_name tuple_pattern?;

// // Optional Pattern
// optional_pattern: identifier_pattern QUESTION;

// // Expression Pattern
// expression_pattern: expression;

// balanced_tokens: balanced_token+;

// balanced_token:
// 	LPAREN balanced_tokens? RPAREN
// 	| LBRACK balanced_tokens? RBRACK
// 	| LCURLY balanced_tokens? RCURLY
// 	//Any identifier, keyword, literal, or operator Any punctuation except (, ), [, ], {, or }
// 	| identifier
// 	| keyword
// 	| literal
// 	| operator
// 	| balanced_token_punctuation;

// balanced_token_punctuation:
// 	(
// 		DOT
// 		| COMMA
// 		| COLON
// 		| SEMI
// 		| EQUAL
// 		| AT
// 		| HASH
// 		| BACKTICK
// 		| QUESTION
// 	)
// 	| arrow_operator
// 	|  AND
// 	|  BANG;

// // // Capture Lists
// // closure_expression:
// // 	LCURLY closure_signature? statements? RCURLY;

// // closure_signature:
// // 	capture_list? closure_parameter_clause THROWS? function_result? IN
// // 	| capture_list IN;

// // closure_parameter_clause:
// // 	LPAREN closure_parameter_list? RPAREN
// // 	| identifier_list;

// // closure_parameter_list:
// // 	closure_parameter (COMMA closure_parameter)*;

// // closure_parameter:
// // 	closure_parameter_name = identifier (
// // 		type_annotation range_operator?
// // 	)?;

// // capture_list: LBRACK capture_list_items RBRACK;

// // capture_list_items:
// // 	capture_list_item (COMMA capture_list_item)*;

// // capture_list_item:
// // 	capture_specifier? (
// // 		identifier EQUAL? expression
// // 		| self_expression
// // 	);

// // capture_specifier:
// // 	WEAK
// // 	| UNOWNED (LPAREN (SAFE | UNSAFE) RPAREN)?;

// // Implicit Member Expression
// implicit_member_expression:
// 	DOT (identifier | keyword) (DOT postfix_expression)?;
// // let a: MyType = .default; static let `default` = MyType()

// // Parenthesized Expression
// parenthesized_operator: LPAREN operator RPAREN;

// // Parenthesized Expression
// parenthesized_expression: LPAREN expression RPAREN;

// // Tuple Expression
// tuple_expression:
// 	LPAREN RPAREN
// 	| LPAREN tuple_element COMMA tuple_element_list RPAREN;

// tuple_element_list: tuple_element (COMMA tuple_element)*;

// tuple_element: (identifier COLON)? expression;

// // Wildcard Expression
// wildcard_expression: UNDERSCORE;

// // Key-Path Expression
// key_path_expression: BACKSLASH type? DOT key_path_components;
// key_path_components:
// 	key_path_component (DOT key_path_component)*;
// key_path_component:
// 	identifier key_path_postfixes?
// 	| key_path_postfixes;
// key_path_postfixes: key_path_postfix+;
// key_path_postfix:
// 	QUESTION
// 	| BANG
// 	| SELF
// 	| LBRACK function_call_argument_list RBRACK;

// // Selector Expression
// selector_expression:
// 	// HASH_SELECTOR 
// 	LPAREN (
// 		// (GETTER | SETTER) 
// 		COLON)? expression RPAREN;

// // Key-Path String Expression
// key_path_string_expression:
// 	// HASH_KEYPATH
// 	LPAREN expression RPAREN;

// // Postfix Expressions

// //The following sets of rules are mutually left-recursive [postfix_expression,
// // function_call_expression, initializer_expression, explicit_member_expression,
// // postfix_self_expression, subscript_expression, forced_value_expression,
// // optional_chaining_expression], to avoid this the rule inner_postfix_expression was implemented.
// /*postfix_expression:
//  postfix_expression postfix_operator | function_call_expression | initializer_expression |
//  explicit_member_expression | postfix_self_expression | subscript_expression |
//  forced_value_expression | optional_chaining_expression | primary_expression ;
//  */

// function_call_suffix:
// 	function_call_argument_clause?
// 	// trailing_closures
// 	| function_call_argument_clause;

// initializer_suffix: DOT INIT (LPAREN argument_names RPAREN)?;

// explicit_member_suffix:
// 	DOT (
// 		Decimal_digits
// 		| identifier (
// 			generic_argument_clause
// 			| LPAREN argument_names RPAREN
// 		)?
// 	);

// postfix_self_suffix: DOT SELF;

// subscript_suffix: LBRACK function_call_argument_list RBRACK;

// forced_value_suffix: {!SwiftSupport.isBinaryOp(_input)}? BANG;
// optional_chaining_suffix:
// 	{!SwiftSupport.isBinaryOp(_input)}? QUESTION;

// // Function Call Expression

// function_call_argument_clause:
// 	LPAREN function_call_argument_list? RPAREN;

// function_call_argument_list:
// 	function_call_argument (COMMA function_call_argument)*;

// function_call_argument:
// 	argument_name? (
// 		identifier /*optimization */
// 		| expression
// 		| operator
// 	);

// // trailing_closures:
// // 	closure_expression labeled_trailing_closures?;

// // labeled_trailing_closures: labeled_trailing_closure+;

// // labeled_trailing_closure: identifier COLON closure_expression;

// argument_names: argument_name+;
// argument_name: identifier COLON;



// // Tuple Type
// tuple_type: LPAREN tuple_type_element_list? RPAREN;
// tuple_type_element_list:
// 	tuple_type_element (COMMA tuple_type_element)*;
// tuple_type_element:
// 	(element_name type_annotation | type) (EQUAL expression)? /* assigning value */;
// element_name:
// 	identifier+; // TODO understand a specific thing - _

// Protocol Composition Type
protocol_composition_type:
	type_identifier (AND type_identifier)* trailing_composition_and?;

trailing_composition_and: AND;

// // Opaque Type
// // opaque_type: SOME type;


// // Self Type
// // self_type: SELF_BIG;

// // Type Inheritance Clause
// type_inheritance_clause: COLON type_inheritance_list;

// type_inheritance_list: type_identifier (COMMA type_identifier)*;

// // Identifiers

// identifier_list: identifier (COMMA identifier)*;

// // Keywords and Punctuation
// keyword:
// 	// Keywords used in declarations
// 	// ASSOCIATED_TYPE
// 	// | CLASS
// 	// | DEINIT
// 	// | ENUM
// 	// | EXTENSION
// 	// | FILE_PRIVATE
// 	FUNC
// 	| IMPORT
// 	| INIT
// 	// | INOUT
// 	// | INTERNAL
// 	| LET
// 	// | OPEN
// 	// | OPERATOR
// 	| PRIVATE
// 	// | PROTOCOL
// 	| PUBLIC
// 	// | RETHROWS
// 	| STATIC
// 	| STRUCT
// 	// | SUBSCRIPT
// 	// | TYPEALIAS
// 	| VAR
// 	// Keywords used in statements
// 	| BREAK
// 	| CASE
// 	| CONTINUE
// 	| DEFAULT
// 	// | DEFER
// 	// | DO
// 	| ELSE
// 	// | FALLTHROUGH
// 	| FOR
// 	// | GUARD
// 	| IF
// 	| IN
// 	// | REPEAT
// 	| RETURN
// 	| SWITCH
// 	// | WHERE
// 	| WHILE
// 	// Keywords used in expressions and types
// 	| AS
// 	| ANY
// 	// | CATCH
// 	| FALSE
// 	| IS
// 	| NIL
// 	| SUPER
// 	| SELF
// 	// | SELF_BIG
// 	| THROW
// 	// | THROWS
// 	| TRUE
// 	| TRY
// 	// Keywords used in patterns
// 	| UNDERSCORE
// 	// Keywords that begin with a number sign (#)
// 	| AVAILABLE
// 	// | HASH_COLOR_LITERAL
// 	// | HASH_COLUMN
// 	// | HASH_ELSE
// 	// | HASH_ELSEIF
// 	// | HASH_ENDIF
// 	| ERROR
// 	// | HASH_FILE
// 	// | HASH_FILE_ID
// 	// | HASH_FILE_LITERAL
// 	// | HASH_FILE_PATH
// 	// | HASH_FUNCTION
// 	// | HASH_IF
// 	// | HASH_IMAGE_LITERAL
// 	// | HASH_LINE
// 	// | HASH_SELECTOR
// 	// | SOURCE_LOCATION
// 	| WARNING;

 