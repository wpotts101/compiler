CXX = g++
CXXFLAGS = -Wall -std=c++11

all: tree_builder

tree_builder: lex.yy.c tree_builder.tab.c
	$(CXX) $(CXXFLAGS) lex.yy.c tree_builder.tab.c -o tree_builder

tree_builder.tab.c tree_builder.tab.h: tree_builder.y
	yacc -d tree_builder.y
	mv y.tab.c tree_builder.tab.c
	mv y.tab.h tree_builder.tab.h

lex.yy.c: tree_builder.l tree_builder.tab.h
	flex tree_builder.l

clean:
	rm -f lex.yy.c tree_builder.tab.c tree_builder.tab.h y.tab.c y.tab.h tree_builder