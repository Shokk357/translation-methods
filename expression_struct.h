#include <deque>

class expression_struct {
public:
    std::deque<int> numbers;
    std::deque<char> operations;
    int value;
};