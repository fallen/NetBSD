//===----------------------------------------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is dual licensed under the MIT and the University of Illinois Open
// Source Licenses. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

// <functional>

// class function<R(ArgTypes...)>

// template<class F>
//   requires CopyConstructible<F> && Callable<F, ArgTypes..>
//         && Convertible<Callable<F, ArgTypes...>::result_type
//   operator=(F f);

#include <functional>
#include <new>
#include <cstdlib>
#include <cassert>

int new_called = 0;

void* operator new(std::size_t s) throw(std::bad_alloc)
{
    ++new_called;
    return std::malloc(s);
}

void  operator delete(void* p) throw()
{
    --new_called;
    std::free(p);
}

class A
{
    int data_[10];
public:
    static int count;

    A()
    {
        ++count;
        for (int i = 0; i < 10; ++i)
            data_[i] = i;
    }

    A(const A&) {++count;}

    ~A() {--count;}

    int operator()(int i) const
    {
        for (int j = 0; j < 10; ++j)
            i += data_[j];
        return i;
    }

    int foo(int) const {return 1;}
};

int A::count = 0;

int g(int) {return 0;}

int main()
{
    assert(new_called == 0);
    {
    std::function<int(int)> f;
    f = A();
    assert(A::count == 1);
    assert(new_called == 1);
    assert(f.target<A>());
    assert(f.target<int(*)(int)>() == 0);
    }
    assert(A::count == 0);
    assert(new_called == 0);
    {
    std::function<int(int)> f;
    f = g;
    assert(new_called == 0);
    assert(f.target<int(*)(int)>());
    assert(f.target<A>() == 0);
    }
    assert(new_called == 0);
    {
    std::function<int(int)> f;
    f = (int (*)(int))0;
    assert(!f);
    assert(new_called == 0);
    assert(f.target<int(*)(int)>() == 0);
    assert(f.target<A>() == 0);
    }
    {
    std::function<int(const A*, int)> f;
    f = &A::foo;
    assert(f);
    assert(new_called == 0);
    assert(f.target<int (A::*)(int) const>() != 0);
    }
}
