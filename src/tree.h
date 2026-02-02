#ifndef TREE_H
#define TREE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_CHILDREN 20

typedef enum {

} NodeType;

typedef struct TreeNode {
    NodeType nodeType;
    char name[64];
    char value[256];
    int line;
    int column;
    int numberof_children;
    struct TreeNode* children[MAX_CHILDREN];
} TreeNode;

const char* getNodeTypeName(NodeType type);
TreeNode* createNode(NodeType type, const char* name, int line, int column);
void addChild(TreeNode* parent, TreeNode* child);
void addChildren(TreeNode* parent, TreeNode* children[]);
void freeTree(TreeNode* node);

#endif