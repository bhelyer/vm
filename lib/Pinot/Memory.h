#ifndef PINOT_MEMORY_H
#define PINOT_MEMORY_H

#include <cstdint>
#include <vector>

namespace Pinot
{

/// Virtualised memory block.
class Memory final
{
    using ByteVec = std::vector<uint8_t>;

    ByteVec mem;

public:
    /// Allocate a memory block of the given size. 
    /// @param size The amount of memory to allocate, in bytes.
    explicit Memory(size_t size);

    /// Copy bytes into the memory.
    /// @param addr The address to start copying at.
    /// @param data The bytes to copy.
    /// @throw WriteException If `addr` or `addr+data.size()-1` is out of bounds.
    void copy(size_t addr, const ByteVec& data);

    // Read a single byte of memory.
    /// @param addr The address to read from.
    /// @return The byte at `addr`.
    /// @throw ReadException If `addr` is out of bounds.
    [[nodiscard]] uint8_t read8(size_t addr) const;

private:
    // If `addr` is out of bounds, throw a WriteException.
    void validateWrite(size_t addr) const;

    // If `addr` is out of bounds, throw a ReadException.
    void validateRead(size_t addr) const;
};

} // namespace Pinot

#endif // PINOT_MEMORY_H