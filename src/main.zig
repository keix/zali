const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

const Atom = union(enum) {
    Number: f64,
    Symbol: []const u8,
    String: []const u8,
    Boolean: bool,
};

const ParserError = error{
    UnexpectedEOF,
    UnmatchedParenthesis,
    InvalidNumber,
    InvalidString,
    OutOfMemory,
};

const EvalError = error{
    InvalidOperation,
    TypeError,
    UnknownSymbol,
    DivisionByZero,
    InvalidArgument,
    OutOfMemory,
};

const builtins = [_]Builtin{
    .{ .name = "+", .func = evalAdd, .min_args = 1 },
    .{ .name = "-", .func = evalSub, .min_args = 1 },
    .{ .name = "*", .func = evalMul, .min_args = 1 },
    .{ .name = "/", .func = evalDiv, .min_args = 1 },
    .{ .name = "=", .func = evalEqual, .min_args = 2 },
    .{ .name = "<=", .func = evalLessEqual, .min_args = 2 },
    .{ .name = ">=", .func = evalGreaterEqual, .min_args = 2 },
    .{ .name = "mod", .func = evalMod, .min_args = 2 },
    .{ .name = "and", .func = evalAnd, .min_args = 2 },
    .{ .name = "if", .func = evalIf, .min_args = 3 },
    .{ .name = "cond", .func = evalCond, .min_args = 2 },
    .{ .name = "define", .func = evalDefine, .min_args = 2 },
    .{ .name = "set!", .func = evalSet, .min_args = 2 },
    .{ .name = "while", .func = evalWhile, .min_args = 2 },
    .{ .name = "print", .func = evalPrint, .min_args = 1 },
};

const BuiltinFn = *const fn ([]const LispValue, *Environment) EvalError!LispValue;

const Builtin = struct {
    name: []const u8,
    func: BuiltinFn,
    min_args: usize,
};

const LispValue = union(enum) {
    Atom: Atom,
    List: ArrayList(LispValue),

    pub fn deinit(self: *LispValue, allocator: Allocator) void {
        switch (self.*) {
            .List => |*list| {
                for (list.items) |*item| {
                    item.deinit(allocator);
                }
                list.deinit();
            },
            .Atom => {},
        }
    }

    pub fn format(
        self: LispValue,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        switch (self) {
            .Atom => |atom| {
                switch (atom) {
                    .Number => |n| try writer.print("{d}", .{n}),
                    .Symbol => |s| try writer.writeAll(s),
                    .String => |s| try writer.print("\"{s}\"", .{s}),
                    .Boolean => |b| try writer.writeAll(if (b) "#t" else "#f"),
                }
            },
            .List => |list| {
                try writer.writeByte('(');
                for (list.items, 0..) |item, i| {
                    if (i > 0) try writer.writeByte(' ');
                    try writer.print("{}", .{item});
                }
                try writer.writeByte(')');
            },
        }
    }
};

const Environment = struct {
    allocator: Allocator,
    vars: std.StringHashMap(LispValue),
    parent: ?*Environment,

    pub fn init(allocator: Allocator, parent: ?*Environment) Environment {
        return .{
            .allocator = allocator,
            .vars = std.StringHashMap(LispValue).init(allocator),
            .parent = parent,
        };
    }

    pub fn deinit(self: *Environment) void {
        var it = self.vars.iterator();
        while (it.next()) |entry| {
            var value = entry.value_ptr;
            value.deinit(self.allocator);
        }
        self.vars.deinit();
    }

    pub fn get(self: *Environment, name: []const u8) !?LispValue {
        if (self.vars.get(name)) |value| {
            return try clone(self.allocator, value);
        }
        if (self.parent) |parent| {
            return try parent.get(name);
        }
        return null;
    }

    pub fn set(self: *Environment, name: []const u8, value: LispValue) !void {
        if (self.vars.getPtr(name)) |old_value| {
            old_value.deinit(self.allocator);
        }

        const value_copy = try clone(self.allocator, value);
        try self.vars.put(name, value_copy);
    }
};

const Parser = struct {
    allocator: Allocator,
    input: []const u8,
    pos: usize,

    pub fn init(allocator: Allocator, input: []const u8) Parser {
        return .{
            .allocator = allocator,
            .input = input,
            .pos = 0,
        };
    }

    pub fn parse(self: *Parser) ParserError!LispValue {
        self.skipSpace();
        if (self.pos >= self.input.len) {
            return error.UnexpectedEOF;
        }

        switch (self.input[self.pos]) {
            '(' => return self.parseList(),
            '"' => return self.parseString(),
            '0'...'9' => return self.parseAtom(),
            else => return self.parseAtom(),
        }
    }

    fn skipSpace(self: *Parser) void {
        while (self.pos < self.input.len and std.ascii.isWhitespace(self.input[self.pos])) {
            self.pos += 1;
        }
    }

    fn parseString(self: *Parser) ParserError!LispValue {
        self.pos += 1; // Skip opening quote
        var end = self.pos;
        while (end < self.input.len and self.input[end] != '"') {
            end += 1;
        }
        if (end >= self.input.len) {
            return error.UnexpectedEOF;
        }
        const str = self.input[self.pos..end];
        self.pos = end + 1; // Skip closing quote
        return LispValue{ .Atom = Atom{ .String = str } };
    }

    fn parseList(self: *Parser) ParserError!LispValue {
        var list = ArrayList(LispValue).init(self.allocator);
        errdefer {
            for (list.items) |*item| {
                item.deinit(self.allocator);
            }
            list.deinit();
        }

        self.pos += 1; // Skip '('

        while (self.pos < self.input.len) {
            self.skipSpace();
            if (self.pos >= self.input.len) {
                return error.UnexpectedEOF;
            }

            if (self.input[self.pos] == ')') {
                self.pos += 1;
                return LispValue{ .List = list };
            }

            const value = try self.parse();
            try list.append(value);
        }
        return error.UnmatchedParenthesis;
    }

    fn parseAtom(self: *Parser) ParserError!LispValue {
        if (std.ascii.isDigit(self.input[self.pos])) {
            var end = self.pos;
            while (end < self.input.len and (std.ascii.isDigit(self.input[end]) or self.input[end] == '.')) {
                end += 1;
            }

            const num = std.fmt.parseFloat(f64, self.input[self.pos..end]) catch {
                return error.InvalidNumber;
            };
            self.pos = end;
            return LispValue{ .Atom = Atom{ .Number = num } };
        }

        var end = self.pos;
        while (end < self.input.len and !std.ascii.isWhitespace(self.input[end]) and self.input[end] != '(' and self.input[end] != ')') {
            end += 1;
        }

        const symbol = self.input[self.pos..end];
        self.pos = end;

        if (std.mem.eql(u8, symbol, "#t")) {
            return LispValue{ .Atom = .{ .Boolean = true } };
        }
        if (std.mem.eql(u8, symbol, "#f")) {
            return LispValue{ .Atom = .{ .Boolean = false } };
        }
        return LispValue{ .Atom = Atom{ .Symbol = symbol } };
    }
};

fn readFile(allocator: Allocator, path: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);

    const bytes_read = try file.readAll(buffer);
    if (bytes_read != file_size) {
        allocator.free(buffer);
        return error.ReadError;
    }
    return buffer;
}

fn makeList(allocator: Allocator, items: []LispValue) !LispValue {
    var list = try allocator.create(ArrayList(LispValue));
    list.* = ArrayList(LispValue).init(allocator);
    errdefer list.deinit();

    for (items) |item| {
        try list.append(item);
    }
    return LispValue{ .List = list.* };
}

pub fn clone(allocator: Allocator, value: LispValue) !LispValue {
    return switch (value) {
        .Atom => value,
        .List => |list| {
            var new_list = ArrayList(LispValue).init(allocator);
            for (list.items) |item| {
                const cloned_item = try clone(allocator, item);
                try new_list.append(cloned_item);
            }
            return LispValue{ .List = new_list };
        },
    };
}

fn eval(value: LispValue, env: *Environment) EvalError!LispValue {
    switch (value) {
        .Atom => |atom| {
            switch (atom) {
                .Number, .String, .Boolean => return value,
                .Symbol => {
                    if (try env.get(atom.Symbol)) |val| {
                        return val;
                    }
                    return EvalError.UnknownSymbol;
                },
            }
        },
        .List => |list| {
            if (list.items.len == 0) {
                return EvalError.InvalidOperation;
            }

            const op = list.items[0];
            if (op != .Atom or op.Atom != .Symbol) {
                return EvalError.InvalidOperation;
            }

            const operator = op.Atom.Symbol;
            for (builtins) |builtin| {
                if (std.mem.eql(u8, operator, builtin.name)) {
                    if (list.items.len - 1 < builtin.min_args) {
                        return EvalError.InvalidArgument;
                    }
                    return builtin.func(list.items[1..], env);
                }
            }
            return EvalError.UnknownSymbol;
        },
    }
}

fn evalAdd(args: []const LispValue, env: *Environment) EvalError!LispValue {
    var sum: f64 = 0;
    for (args) |arg| {
        const val = try eval(arg, env);
        if (val != .Atom or val.Atom != .Number) {
            return EvalError.TypeError;
        }
        sum += val.Atom.Number;
    }
    return LispValue{ .Atom = .{ .Number = sum } };
}

fn evalSub(args: []const LispValue, env: *Environment) EvalError!LispValue {
    if (args.len < 1) return EvalError.InvalidArgument;
    const first = try eval(args[0], env);
    if (first != .Atom or first.Atom != .Number) {
        return EvalError.TypeError;
    }
    var result = first.Atom.Number;

    for (args[1..]) |arg| {
        const val = try eval(arg, env);
        if (val != .Atom or val.Atom != .Number) {
            return EvalError.TypeError;
        }
        result -= val.Atom.Number;
    }
    return LispValue{ .Atom = .{ .Number = result } };
}

fn evalMul(args: []const LispValue, env: *Environment) EvalError!LispValue {
    var result: f64 = 1;
    for (args) |arg| {
        const val = try eval(arg, env);
        if (val != .Atom or val.Atom != .Number) {
            return EvalError.TypeError;
        }
        result *= val.Atom.Number;
    }
    return LispValue{ .Atom = .{ .Number = result } };
}

fn evalDiv(args: []const LispValue, env: *Environment) EvalError!LispValue {
    if (args.len < 1) return EvalError.InvalidArgument;
    const first = try eval(args[0], env);
    if (first != .Atom or first.Atom != .Number) {
        return EvalError.TypeError;
    }
    var result = first.Atom.Number;

    for (args[1..]) |arg| {
        const val = try eval(arg, env);
        if (val != .Atom or val.Atom != .Number) {
            return EvalError.TypeError;
        }
        if (val.Atom.Number == 0) {
            return EvalError.DivisionByZero;
        }
        result /= val.Atom.Number;
    }
    return LispValue{ .Atom = .{ .Number = result } };
}

fn evalMod(args: []const LispValue, env: *Environment) EvalError!LispValue {
    if (args.len != 2) return EvalError.InvalidArgument;
    const a = try eval(args[0], env);
    const b = try eval(args[1], env);
    if (a != .Atom or a.Atom != .Number or b != .Atom or b.Atom != .Number) {
        return EvalError.TypeError;
    }
    if (b.Atom.Number == 0) {
        return EvalError.DivisionByZero;
    }
    const result = @mod(@as(i32, @intFromFloat(a.Atom.Number)), @as(i32, @intFromFloat(b.Atom.Number)));
    return LispValue{ .Atom = .{ .Number = @as(f64, @floatFromInt(result)) } };
}

fn evalEqual(args: []const LispValue, env: *Environment) EvalError!LispValue {
    if (args.len != 2) return EvalError.InvalidArgument;
    const a = try eval(args[0], env);
    const b = try eval(args[1], env);
    if (a != .Atom or a.Atom != .Number or b != .Atom or b.Atom != .Number) {
        return EvalError.TypeError;
    }
    return LispValue{ .Atom = .{ .Boolean = a.Atom.Number == b.Atom.Number } };
}

fn evalLessEqual(args: []const LispValue, env: *Environment) EvalError!LispValue {
    if (args.len != 2) return EvalError.InvalidArgument;
    const a = try eval(args[0], env);
    const b = try eval(args[1], env);
    if (a != .Atom or a.Atom != .Number or b != .Atom or b.Atom != .Number) {
        return EvalError.TypeError;
    }
    return LispValue{ .Atom = .{ .Boolean = a.Atom.Number <= b.Atom.Number } };
}

fn evalGreaterEqual(args: []const LispValue, env: *Environment) EvalError!LispValue {
    if (args.len != 2) return EvalError.InvalidArgument;
    const a = try eval(args[0], env);
    const b = try eval(args[1], env);
    if (a != .Atom or a.Atom != .Number or b != .Atom or b.Atom != .Number) {
        return EvalError.TypeError;
    }
    return LispValue{ .Atom = .{ .Boolean = a.Atom.Number >= b.Atom.Number } };
}

fn evalAnd(args: []const LispValue, env: *Environment) EvalError!LispValue {
    for (args) |arg| {
        const val = try eval(arg, env);
        if (val != .Atom or val.Atom != .Boolean) {
            return EvalError.TypeError;
        }
        if (!val.Atom.Boolean) {
            return LispValue{ .Atom = .{ .Boolean = false } };
        }
    }
    return LispValue{ .Atom = .{ .Boolean = true } };
}

fn evalIf(args: []const LispValue, env: *Environment) EvalError!LispValue {
    if (args.len != 3) return EvalError.InvalidArgument;
    const condition = try eval(args[0], env);
    if (condition != .Atom or condition.Atom != .Boolean) {
        return EvalError.TypeError;
    }
    return if (condition.Atom.Boolean)
        try eval(args[1], env)
    else
        try eval(args[2], env);
}

fn evalCond(args: []const LispValue, env: *Environment) EvalError!LispValue {
    for (0..args.len / 2) |i| {
        const condition = try eval(args[i * 2], env);
        if (condition != .Atom or condition.Atom != .Boolean) {
            return EvalError.TypeError;
        }
        if (condition.Atom.Boolean) {
            return try eval(args[i * 2 + 1], env);
        }
    }
    return LispValue{ .Atom = .{ .Boolean = false } };
}

fn evalDefine(args: []const LispValue, env: *Environment) EvalError!LispValue {
    if (args.len != 2) return EvalError.InvalidArgument;
    if (args[0] != .Atom or args[0].Atom != .Symbol) {
        return EvalError.TypeError;
    }
    const name = args[0].Atom.Symbol;
    const value = try eval(args[1], env);
    try env.set(name, value);
    return value;
}

fn evalSet(args: []const LispValue, env: *Environment) EvalError!LispValue {
    if (args.len != 2) return EvalError.InvalidArgument;
    if (args[0] != .Atom or args[0].Atom != .Symbol) {
        return EvalError.TypeError;
    }
    const name = args[0].Atom.Symbol;
    const value = try eval(args[1], env);
    try env.set(name, value);
    return value;
}

fn evalWhile(args: []const LispValue, env: *Environment) EvalError!LispValue {
    if (args.len < 2) return EvalError.InvalidArgument;
    while (true) {
        const condition = try eval(args[0], env);
        if (condition != .Atom or condition.Atom != .Boolean) {
            return EvalError.TypeError;
        }
        if (!condition.Atom.Boolean) break;

        for (args[1..]) |body| {
            _ = try eval(body, env);
        }
    }
    return LispValue{ .Atom = .{ .Number = 0 } };
}

fn evalPrint(args: []const LispValue, env: *Environment) EvalError!LispValue {
    if (args.len != 1) return EvalError.InvalidArgument;
    var value = try eval(args[0], env);
    defer value.deinit(env.allocator);

    if (value == .Atom and value.Atom == .String) {
        std.debug.print("{s}", .{value.Atom.String});
    } else if (value == .Atom and value.Atom == .Number) {
        const int_value = @as(i32, @intFromFloat(value.Atom.Number));
        std.debug.print("{d}", .{int_value});
    } else {
        std.debug.print("{}", .{value});
    }
    std.debug.print("\n", .{});

    return try clone(env.allocator, value);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const check = gpa.deinit();
        if (check == .leak) {
            @panic("Memory leak detected!");
        }
    }
    const allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    _ = args.skip();

    const file_path = args.next() orelse {
        std.debug.print("Usage: {s} <script.lisp>\n", .{std.os.argv[0]});
        return error.InvalidArgument;
    };

    const source = try readFile(allocator, file_path);
    defer allocator.free(source);

    var global_env = Environment.init(allocator, null);
    defer global_env.deinit();

    var parser = Parser.init(allocator, source);
    while (true) {
        var expr = parser.parse() catch |err| switch (err) {
            error.UnexpectedEOF => break,
            else => return err,
        };

        var result = try eval(expr, &global_env);
        result.deinit(allocator);
        expr.deinit(allocator);
    }
}
