/**
 * Authors: William Potts and Nathan Beasley
 * 
 * Definition: This creates a parse tree for information. Allows to store all the information of created nodes of a tree
 *             and other information such as variables for loops and other misc. tasks.
 * 
 * Last edited: 4/21/26
 */
#ifndef PARSE_TREE_H
#define PARSE_TREE_H

#include <string>
#include <map> //for variable table and parse tree
#include <iostream>
#include <stdexcept> //used to trow exceptions
#include "tree_node.h" //used for tree nodes

class ParseTree;

class IntExpr 
{
    public:
        virtual int eval(ParseTree& tree) = 0;
        virtual ~IntExpr() {}
};

class StringExpr
{
    public:
        virtual std::string eval(ParseTree& tree) = 0;
        virtual ~StringExpr() {}
};

class Statement
{
    public:
        virtual void execute(ParseTree& tree) = 0;
        virtual ~Statement() {}
};

class ParseTree
{
    private:
        std::map<std::string, TreeNode*> nodes;
        std::map<std::string, int> variables; //symbol table
        std::map<std::string, std::string> stringVars;
    
    public:
        /**
         * @def - deconstructor of a parse tree, deletes all nodes currently created
         * 
         */
        ~ParseTree()
        {
            for(auto& p : nodes)
            {
                delete p.second;
            }
        }  

        /**
         * @def - puts name of the variable and its corresponding value in variable table
         * 
         * @arg var - name of the variable
         * @arg value - value for corresponding variable
         * 
         */

        void setString(const std::string& var, const std::string& val)
    {
        stringVars[var] = val;
    }

        std::string getString(const std::string& var) const
    {
        auto it = stringVars.find(var);
        if(it == stringVars.end())
            throw std::runtime_error("Undefined string variable: " + var);
        return it->second;
    }

        void setVariable(const std::string& var, int value)
        {
            variables[var] = value;
        }

        /**
         * @def - finds set value of a given variable
         * 
         * @arg var - variable you are looking for the balue of
         * 
         * @return int - value corresponding to the variable
         */
        int getVariable(const std::string var) const
        {
            auto it = variables.find(var); //finds the variable
            if(it == variables.end()) //if the variable it is past the end of the table then it doesn't exist
            {
                throw std::runtime_error("Undefined Variable: " + var);
            }
            return it->second;
        }

        /**
         * @def - checks whether a variable has a value
         * 
         * @arg var - variable you are checking if it has a value
         * 
         * @return bool - true if the variable has a value, false if not
         */
        bool hasVariable(const std::string var) const
        {
            return variables.count(var) > 0; //counts if the variable appears in the variable table
        }

        /**
         * @def - creates a new node and puts it within the parse tree and adds it to the children list of its parent
         * 
         * @arg name - name of the new node being created
         * @arg weight - value the node holds
         * @arg parentName - the parent of the new node, if the node is a root then it is left empty
         *
         */
        void buildNode(const std::string& name, int weight, const std::string& parentName = "")
        {
            if(nodes.count(name)) //checks to make sure a node of the same name doesn't already exist
            {
                throw std::runtime_error("Node already exists: " + name);
            }
            TreeNode* newNode = new TreeNode(name, weight);
            nodes[name] = newNode;

            if(!parentName.empty()) //checks to see if the node is a root of child
            {
                auto it = nodes.find(parentName);
                if(it == nodes.end()) //checks to see if parent exists
                {
                    throw std::runtime_error("Parent node does not exist: " + parentName);
                }
                it->second->addChild(newNode); //adds new node to the list of parents children
            }
        }

        /**
         * @def - returns node given it's name
         * 
         * @arg name - name of node you are looking for
         * 
         * @return TreeNode* - returns pointer to the node information
         */
        TreeNode* getNode(const std::string& name) const
        {
            auto it = nodes.find(name);
            if(it == nodes.end()) //checks that node exists
            {
                throw std::runtime_error("Node does not exist: " + name);
            }
            return it->second;
        }

        /**
         * @def - prints tree starting at given node name
         * 
         * @arg name - name of node that you want to start printing at
         */
        void printTree(const std::string& name) const
        {
            TreeNode* root = getNode(name); //gets information of node given
            if(!root) //makes sure it exists and found something
            {
                throw std::runtime_error("Tree root not found: " + name);
            }
            root->print(std::cout);
            std::cout << std::endl;
        }


};

class IntLiteral : public IntExpr
{
    private:
        int value;
    public:
    IntLiteral(int v) : value(v) {}

    int eval(ParseTree& tree) override
    {
        return value;
    }
};

class IntVariable : public IntExpr
{
    private:
        std::string name;
    public:
        IntVariable(const std::string& n) : name(n) {}

        int eval(ParseTree& tree) override
        {
            return tree.getVariable(name);
        }
};

class IntAddExpr : public IntExpr
{
    private:
        IntExpr* left;
        IntExpr* right;
    public:
        IntAddExpr(IntExpr* l, IntExpr* r) : left(l), right(r) {}

        int eval(ParseTree& tree) override
        {
            return left->eval(tree) + right->eval(tree);
        }

        ~IntAddExpr()
        {
            delete left;
            delete right;
        }
};

class StringLiteral : public StringExpr
{
    private:
        std::string value;
    public:
        StringLiteral(const std::string& v) : value(v) {}

        std::string eval(ParseTree& tree) override
        {
            return value;
        }
};

class StringFromIntExpr : public StringExpr
{
    private:
        IntExpr* expr;
    public:
        StringFromIntExpr(IntExpr* e) : expr(e) {}

        std::string eval(ParseTree& tree) override
        {
            return std::to_string(expr->eval(tree));
        }

        ~StringFromIntExpr()
        {
            delete expr;
        }
};

class StringConcatExpr : public StringExpr {
    private:
        StringExpr* left;
        StringExpr* right;

    public:
        StringConcatExpr(StringExpr* l, StringExpr* r) : left(l), right(r) {}

        std::string eval(ParseTree& tree) override {
            return left->eval(tree) + right->eval(tree);
        }

        ~StringConcatExpr() {
            delete left;
            delete right;
        }
};

class BuildNodeStatement : public Statement {
private:
    StringExpr* nameExpr;
    IntExpr* weightExpr;
    StringExpr* parentExpr;   // can be nullptr

public:
    BuildNodeStatement(StringExpr* n, IntExpr* w, StringExpr* p = nullptr)
        : nameExpr(n), weightExpr(w), parentExpr(p) {}

    void execute(ParseTree& tree) override {
        std::string name = nameExpr->eval(tree);
        int weight = weightExpr->eval(tree);
        std::string parent = "";

        if (parentExpr != nullptr) {
            parent = parentExpr->eval(tree);
        }

        tree.buildNode(name, weight, parent);
    }

    ~BuildNodeStatement() {
        delete nameExpr;
        delete weightExpr;
        delete parentExpr;
    }
};

class PrintStatement : public Statement {
private:
    StringExpr* rootExpr;

public:
    PrintStatement(StringExpr* r) : rootExpr(r) {}

    void execute(ParseTree& tree) override {
        tree.printTree(rootExpr->eval(tree));
    }

    ~PrintStatement() {
        delete rootExpr;
    }
};

class BlockStatement : public Statement {
private:
    std::vector<Statement*> statements;

public:
    BlockStatement() {}

    void addStatement(Statement* stmt) {
        statements.push_back(stmt);
    }

    const std::vector<Statement*>& getStatements() const {
        return statements;
    }

    void execute(ParseTree& tree) override {
        for (Statement* stmt : statements) {
            stmt->execute(tree);
        }
    }

    ~BlockStatement() {
        for (Statement* stmt : statements) {
            delete stmt;
        }
    }
};

class ForStatement : public Statement {
private:
    std::string varName;
    IntExpr* startExpr;
    IntExpr* endExpr;
    BlockStatement* body;

public:
    ForStatement(const std::string& v, IntExpr* s, IntExpr* e, BlockStatement* b)
        : varName(v), startExpr(s), endExpr(e), body(b) {}

    void execute(ParseTree& tree) override {
        int start = startExpr->eval(tree);
        int end = endExpr->eval(tree);

        for (int i = start; i <= end; i++) {
            tree.setVariable(varName, i);
            body->execute(tree);
        }
    }

    ~ForStatement() {
        delete startExpr;
        delete endExpr;
        delete body;
    }
};


#endif