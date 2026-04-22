/**
 * Authors: William Potts and Nathan Beasley
 * 
 * Definition: This is the basic blueprint for all nodes
 * 
 * last edited: 4/21/26
 */
#ifndef TREE_NODE_H
#define TREE_NODE_H

#include <string>
#include <vector>
#include <iostream>


class TreeNode
{
    public:
        std::string name; 
        int weight;
        std::vector<TreeNode*> children; // list of nodes children

        TreeNode(const std::string& n, int w) : name(n), weight(w) {}

        //adds a child to the list of children
        void addChild(TreeNode* child) 
        {
            children.push_back(child);
        }

        //prints itself and all of it's children
        // and all of childrens children recursively
        void print(std::ostream& os) const
        {
            os << name;
            if(!children.empty())
            {
                os << " [ ";
                for(size_t i = 0; i < children.size(); i++)
                {
                    children[i]->print(os); //recursive call for children to print its children
                    if(i+1 < children.size())
                    {
                        os << ", ";
                    }
                }
                os << " ]";
            }
        }
};

#endif