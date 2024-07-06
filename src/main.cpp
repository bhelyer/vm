#include "Pinot/Memory.h"
#include "Pinot/VM.h"

int main(int argc, char** argv)
{
    // load r0, 42      2 0 42
    // halt             1
    std::vector<uint8_t> prog{2, 0, 42, 1};
    Pinot::Memory mem(prog.size() + 1);
    mem.copy(0, prog);
    Pinot::VM vm(mem);
    vm.run();
    return vm.read64(Pinot::Register::R0);
}