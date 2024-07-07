#ifndef PINOT_VM_H
#define PINOT_VM_H

#include <array>
#include <cstdint>

namespace Pinot
{

class Memory;

/// Opcodes for the virtual machine's instructions.
enum class Op : uint8_t
{
    Nop,        ///< Do nothing.
    Halt,       ///< Halt execution.
    LoadRC8,    ///< load <reg>, <constant u8>
    LoadRC64,   ///< load <reg>, <constant u64>
    Interrupt,  ///< interrupt <constant u8>
    Max,        ///< Do not use.
};

enum class Register : uint8_t
{
    R0,
    R1,
    R2,
    R3,
    R4,
    R5,
    R6,
    R7,
    R8,
    R9,
    R10,
    R11,
    R12,
    R13,
    R14,
    R15,
    R16,
    R17,
    R18,
    R19,
    R20,
    R21,
    R22,
    R23,
    R24,
    R25,
    R26,
    R27,
    R28,
    R29,
    R30,
    R31,
    IP,         ///< Instruction pointer.
    SP,         ///< Stack pointer.
    Max,        ///< Do not use.
};

constexpr uint8_t PINOT_BUILTIN = 0;

// When `interrupt 0` is run, the value in r0 identifies the operation.
enum class Builtin : uint64_t
{
    /// r0=0, r1=pointer to string, r2=string length, r3=!0 to append newline
    Print,
};

class VM final
{
    Memory& mem;
    std::array<uint64_t, static_cast<size_t>(Register::Max)> regs;

public:
    /// Construct a VM that uses the given memory. Registers start zeroed.
    explicit VM(Memory& mem) noexcept;

    /// Execute the program until it completes.
    void run();

    /// Read the value of a register.
    /// @param reg The register to read.
    /// @throws ReadException The register given was invalid.
    [[nodiscard]] uint64_t read64(Register reg) const;

    /// Write the value of a register.
    /// @param reg The register to write.
    /// @param value The new value of the register.
    /// @throws WriteException The register given was invalid.
    void write(Register reg, uint64_t value);

    /// Invoked when the interrupt instruction is run.
    /// @param value The constant byte given to the interrupt instruction.
    virtual void interrupt(uint8_t value);

private:
    void builtin_print();
};

} // namespace Pinot

#endif // PINOT_VM_H