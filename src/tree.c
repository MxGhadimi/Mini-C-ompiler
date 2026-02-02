#include "tree.h"
#define MAX_NAME_LEN 64
#define MAX_VALUE_LEN 264

const char* getNodeTypeName(NodeType type) {

}

TreeNode* createNode(NodeType type, const char* name, int line, int column) {
    TreeNode* node = (TreeNode*)malloc(sizeof(TreeNode));
    if (node == NULL) {
        fprintf(stderr, "node creation failed for TreeNode\n");
        exit(1);
    }
    
    node->nodeType = type;
    
    if (name != NULL && strlen(name) > 0) {
        strncpy(node->name, name, MAX_NAME_LEN - 1);
        node->name[MAX_NAME_LEN - 1] = '\0';
    } 
    else {
        strncpy(node->name, getNodeTypeName(type), MAX_NAME_LEN - 1);
        node->name[MAX_NAME_LEN - 1] = '\0';
    }
    
    node->value[0] = '\0';
    node->line = line;
    node->column = column;
    node->numberof_children = 0;
    
    for (int i = 0; i < MAX_CHILDREN; i++)
        node->children[i] = NULL;
    
    return node;
}

TreeNode* createNodeWithValue(NodeType type, const char* name, const char* value, int line, int column) {
    TreeNode* node = createNode(type, name, line, column);
    
    if (value != NULL) {
        strncpy(node->value, value, MAX_VALUE_LEN - 1);
        node->value[MAX_VALUE_LEN - 1] = '\0';
    }
    
    return node;
}

void addChild(TreeNode* parent, TreeNode* child) {
    if (parent == NULL || child == NULL) return;
    
    if (parent->numberof_children < MAX_CHILDREN) {
        parent->children[parent->numberof_children] = child;
        parent->numberof_children++;
    } else fprintf(stderr, "Error: Maximum children (%d) exceeded for node '%s'\n", MAX_CHILDREN, parent->name);
}

void addChildren(TreeNode* parent, TreeNode* children[]) {
    if (parent == NULL || children == NULL) return;
    
    int i = 0;
    while (children[i] != NULL) {
        addChild(parent, children[i]);
        i++;
    }
}

void freeTree(TreeNode* node) {
    if (node == NULL) return;
    for (int i = 0; i < node->numberof_children; i++) {
        freeTree(node->children[i]);
        node->children[i] = NULL;
    }

    free(node);
}