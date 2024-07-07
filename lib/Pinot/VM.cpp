#include "Pinot/VM.h"

#include <iostream>

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
        case Op::LoadRC64:
        {
            const uint8_t dst_addr = read64(Register::IP);
            const auto dst = static_cast<Register>(mem.read8(dst_addr));
            write(Register::IP, dst_addr + 1);

            const auto val_addr = dst_addr + 1;
            const auto val = mem.read64(val_addr);
            write(Register::IP, val_addr + sizeof(uint64_t));
            write(dst, val);

            break;
        }
        case Op::Interrupt:
        {
            const uint64_t val_addr = read64(Register::IP);
            const uint8_t val = mem.read8(val_addr);
            write(Register::IP, val_addr + 1);
            interrupt(val);
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

void VM::interrupt(uint8_t value)
{
    if (value != PINOT_BUILTIN)
    {
        return;
    }
    const uint64_t builtin_no = read64(Register::R0);
    switch (static_cast<Builtin>(builtin_no)) {
    case Builtin::Print: builtin_print(); break;
    default: break;
    }
}

void VM::builtin_print()
{
    uint64_t str_addr = read64(Register::R1);
    uint64_t len = read64(Register::R2);
    const bool newline = read64(Register::R3) != 0;

    for (; len > 0; --len)
    {
        std::cout << mem.read8(str_addr);
        ++str_addr;
    }
    if (newline)
    {
        std::cout << '\n';
    }
}

} // namespace Pinot