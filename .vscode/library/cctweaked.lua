---@meta

-- ==========================================================
-- CC: Tweaked Global APIs and Types
-- ==========================================================

---@class Colors
---@field white number
---@field orange number
---@field magenta number
---@field lightBlue number
---@field yellow number
---@field lime number
---@field pink number
---@field gray number
---@field lightGray number
---@field cyan number
---@field purple number
---@field blue number
---@field brown number
---@field green number
---@field red number
---@field black number
---@field combine fun(...: number): number
---@field subtract fun(colors: number, ...: number): number
---@field test fun(colors: number, color: number): boolean
---@field packRGB fun(r: number, g: number, b: number): number
---@field unpackRGB fun(rgb: number): number, number, number
---@field toBlit fun(color: number): string
colors = {}
colours = colors

---@class MonitorPeripheral
---@field setTextScale fun(scale: number)
---@field getTextScale fun(): number
---@field write fun(text: string)
---@field scroll fun(n: number)
---@field setCursorPos fun(x: number, y: number)
---@field getCursorPos fun(): number, number
---@field setCursorBlink fun(blink: boolean)
---@field getCursorBlink fun(): boolean
---@field getSize fun(): number, number
---@field clear fun()
---@field clearLine fun()
---@field setTextColor fun(color: number)
---@field setTextColour fun(colour: number)
---@field setBackgroundColor fun(color: number)
---@field setBackgroundColour fun(colour: number)
---@field getTextColor fun(): number
---@field getTextColour fun(): number
---@field getBackgroundColor fun(): number
---@field getBackgroundColour fun(): number
---@field isColor fun(): boolean
---@field isColour fun(): boolean
---@field blit fun(text: string, textColors: string, backgroundColors: string)

---@class ModemPeripheral
---@field open fun(channel: number)
---@field isOpen fun(channel: number): boolean
---@field close fun(channel: number)
---@field closeAll fun()
---@field transmit fun(channel: number, replyChannel: number, payload: any)
---@field isWireless fun(): boolean

---@class Peripheral
---@field find fun(type: "monitor"|"modem"|string, filter?: fun(name: string, wrapped: any): boolean): any|MonitorPeripheral|ModemPeripheral
---@field getNames fun(): string[]
---@field isPresent fun(name: string): boolean
---@field getType fun(peripheral: string|table): string?
---@field getName fun(peripheral: table): string?
---@field getMethods fun(name: string): string[]?
---@field wrap fun(name: string): table?
---@field call fun(name: string, method: string, ...): any
peripheral = {}

---@class Rednet
---@field CHANNEL_BROADCAST number
---@field CHANNEL_REPEAT number
---@field open fun(modem: string|table)
---@field close fun(modem?: string|table)
---@field isOpen fun(modem?: string|table): boolean
---@field send fun(recipient: number, message: any, protocol?: string): boolean
---@field broadcast fun(message: any, protocol?: string)
---@field receive fun(protocolFilter?: string, timeout?: number): number?, any?, string?
---@field host fun(protocol: string, hostname: string)
---@field unhost fun(protocol: string, hostname?: string)
---@field lookup fun(protocol: string, hostname?: string): any
---@field run fun()
rednet = {}

---@class Terminal
---@field write fun(text: string)
---@field scroll fun(n: number)
---@field setCursorPos fun(x: number, y: number)
---@field getCursorPos fun(): number, number
---@field setCursorBlink fun(blink: boolean)
---@field getCursorBlink fun(): boolean
---@field getSize fun(): number, number
---@field clear fun()
---@field clearLine fun()
---@field setTextColor fun(color: number)
---@field setTextColour fun(colour: number)
---@field setBackgroundColor fun(color: number)
---@field setBackgroundColour fun(colour: number)
---@field getTextColor fun(): number
---@field getTextColour fun(): number
---@field getBackgroundColor fun(): number
---@field getBackgroundColour fun(): number
---@field isColor fun(): boolean
---@field isColour fun(): boolean
---@field blit fun(text: string, textColors: string, backgroundColors: string)
---@field redirect fun(target: Terminal): Terminal
---@field current fun(): Terminal
---@field native fun(): Terminal
term = {}

---@class Keys
---@field enter number
---@field space number
---@field backspace number
---@field up number
---@field down number
---@field left number
---@field right number
---@field [string] number
keys = {}

---@class OS
---@field pullEvent fun(target?: string): string, any, any, any, any, any
---@field pullEventRaw fun(target?: string): string, any, any, any, any, any
---@field queueEvent fun(name: string, ...: any)
---@field clock fun(): number
---@field startTimer fun(timeout: number): number
---@field cancelTimer fun(token: number)
---@field time fun(locale?: string): number
---@field sleep fun(time: number)
---@field day fun(locale?: string): number
---@field setAlarm fun(time: number): number
---@field cancelAlarm fun(token: number)
---@field shutdown fun()
---@field reboot fun()
---@field computerID fun(): number
---@field getComputerID fun(): number
---@field computerLabel fun(): string?
---@field getComputerLabel fun(): string?
---@field setComputerLabel fun(label?: string)
---@field epoch fun(locale?: string): number
---@field date fun(format?: string, time?: number): string|table
os = {}

---@class FS
---@field list fun(path: string): string[]
---@field exists fun(path: string): boolean
---@field isDir fun(path: string): boolean
---@field isReadOnly fun(path: string): boolean
---@field getName fun(path: string): string
---@field getDrive fun(path: string): string?
---@field getSize fun(path: string): number
---@field getFreeSpace fun(path: string): number
---@field makeDir fun(path: string)
---@field move fun(from: string, to: string)
---@field copy fun(from: string, to: string)
---@field delete fun(path: string)
---@field combine fun(base: string, ...: string): string
---@field open fun(path: string, mode: string): any
---@field find fun(wildcard: string): string[]
---@field getDir fun(path: string): string
fs = {}

---@class Textutils
---@field serialize fun(t: any, opts?: table): string
---@field unserialize fun(s: string): any
---@field serializeJSON fun(t: any, nbtStyle?: boolean): string
---@field unserializeJSON fun(s: string, opts?: table): any
---@field urlEncode fun(str: string): string
---@field tabulate fun(...: table)
---@field pagedTabulate fun(...: table)
---@field emptyHTML fun(): string
textutils = {}

---@param time number
function sleep(time) end

---@param text string
function write(text) end

---@param ... any
function printError(...) end

---@param replaceChar? string
---@param history? string[]
---@param completeFn? fun(partial: string): string[]
---@param default? string
---@return string
function read(replaceChar, history, completeFn, default) end
