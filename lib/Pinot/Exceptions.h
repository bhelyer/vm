#ifndef PINOT_EXCEPTIONS_H
#define PINOT_EXCEPTIONS_H

#include <string>
#include <stdexcept>
#include <utility>
#include <format>
#include <cstdint>

namespace Pinot
{

/// Base class for all Pinot exceptions.
class Exception : public std::exception
{
    std::string msg;

public:
    /// Construct a new Exception object.
    /// @param msg A message explaining the exception.
    explicit Exception(const std::string& msg) : msg(std::move(msg)) {}

    virtual const char* what() const noexcept override { return msg.c_str(); }
};

class WriteException final : public Exception
{
public:
    WriteException() : Exception("Tried to write out of bounds.") {}
};

class ReadException final : public Exception
{
public:
    ReadException() : Exception("Tried to read out of bounds.") {}
};

class UnknownInstructionException final : public Exception
{
public:
    UnknownInstructionException(uint8_t opcode) : Exception(std::format(
        "Unknown opcode: {}", static_cast<int>(opcode)
    )) {}
};

} // namespace Pinot

#endif // PINOT_EXCEPTIONS_H