#include "Memory.h"

#include "Pinot/Exceptions.h"

namespace Pinot
{

Memory::Memory(size_t size) : mem(size)
{
}

void Memory::copy(size_t addr, const ByteVec& data)
{
    validateWrite(addr);
    validateWrite(addr + data.size() - 1);
    std::copy(data.begin(), data.end(), mem.begin() + addr);
}

[[nodiscard]] uint8_t Memory::read8(size_t addr) const
{
    validateRead(addr);
    return mem[addr];
}

void Memory::validateWrite(size_t addr) const
{
    if (addr >= mem.size())
    {
        throw WriteException();
    }
}

void Memory::validateRead(size_t addr) const
{
    if (addr >= mem.size())
    {
        throw ReadException();
    }
}

} // namespace Pinot