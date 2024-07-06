#include "Pinot/VM.h"

#include "Pinot/Exceptions.h"
#include "Pinot/Memory.h"

namespace Pinot
{

VM::VM(Memory& mem) noexcept : mem(mem), regs{}
{
}

void VM::run()
{
    while (true)
    {
        // Fetch.
        const uint8_t ip = read64(Register::IP);
        const uint8_t op_byte = mem.read8(ip);
        if (op_byte >= static_cast<uint8_t>(Op::Max))
        {
            throw UnknownInstructionException(op_byte);
        }
        write(Register::IP, ip + 1);

        // Decode.
        const auto op = static_cast<Op>(op_byte);

        // Execute.
        switch (op) {
        case Op::Nop:
        {
            break;
        }
        case Op::Halt:
        {
            return;
        }
        case Op::LoadRC8:
        {
            const uint8_t dst_addr = read64(Register::IP);
            const auto dst = static_cast<Register>(mem.read8(dst_addr));
            write(Register::IP, dst_addr + 1);
            const auto val_addr = dst_addr + 1;
            const auto val = mem.read8(val_addr);
            write(Register::IP, val_addr + 1);
            write(dst, val);
            break;
        }
        default:
            throw UnknownInstructionException(op_byte);
        }
    }
}

uint64_t VM::read64(Register reg) const
{
    const auto index = static_cast<size_t>(reg);
    if (index >= regs.size())
    {
        throw ReadException();
    }
    return regs[index];
}

void VM::write(Register reg, uint64_t value)
{
    const auto index = static_cast<size_t>(reg);
    if (index >= regs.size())
    {
        throw WriteException();
    }
    regs[index] = value;
}

} // namespace Pinot