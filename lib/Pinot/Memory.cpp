#include "Memory.h"

#include <cstring>

#include "Pinot/Exceptions.h"

namespace Pinot
{

namespace
{
[[nodiscard]] uint64_t endian_swap(uint64_t value) noexcept
{
    return ((value & 0x00000000000000FFULL) << 56) |
        ((value & 0x000000000000FF00ULL) << 40) |
        ((value & 0x0000000000FF0000ULL) << 24) |
        ((value & 0x00000000FF000000ULL) << 8)  |
        ((value & 0x000000FF00000000ULL) >> 8)  |
        ((value & 0x0000FF0000000000ULL) >> 24) |
        ((value & 0x00FF000000000000ULL) >> 40) |
        ((value & 0xFF00000000000000ULL) >> 56);
}
}

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

[[nodiscard]] uint64_t Memory::read64(size_t addr) const
{
    validateReadRange(addr, sizeof(uint64_t));
    // TODO: Big endian host systems.
    uint64_t value;
    memcpy(&value, &mem[0] + addr, sizeof(uint64_t));
    value = endian_swap(value);
    return value;
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
        throw ReadException(addr);
    }
}

void Memory::validateReadRange(size_t addr, size_t bytes) const
{
    if (addr >= mem.size() || addr + bytes - 1 >= mem.size())
    {
        throw ReadException(addr, bytes);
    }
}

} // namespace Pinot