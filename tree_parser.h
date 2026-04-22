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


#endif