---@meta

-- ==========================================================
-- Basalt 2.5 LuaCATS Type Definitions
-- ==========================================================

---@class BasaltState
---@field get fun(self: BasaltState): any
---@field set fun(self: BasaltState, value: any)

---@class ElementProps
---@field x? number
---@field y? number
---@field z? number
---@field width? number
---@field height? number
---@field visible? boolean
---@field foreground? number
---@field background? number|boolean
---@field name? string
---@field disabled? boolean

---@class Element
---@field x number
---@field y number
---@field z number
---@field width number
---@field height number
---@field visible boolean
---@field foreground number
---@field background number|boolean
---@field name string
---@field disabled boolean
---@field setX fun(self: self, x: number): self
---@field getX fun(self: self): number
---@field setY fun(self: self, y: number): self
---@field getY fun(self: self): number
---@field setZ fun(self: self, z: number): self
---@field getZ fun(self: self): number
---@field setWidth fun(self: self, width: number): self
---@field getWidth fun(self: self): number
---@field setHeight fun(self: self, height: number): self
---@field getHeight fun(self: self): number
---@field setSize fun(self: self, width: number, height: number): self
---@field getSize fun(self: self): number, number
---@field setPosition fun(self: self, x: number, y: number): self
---@field getPosition fun(self: self): number, number
---@field setBounds fun(self: self, x: number, y: number, width: number, height: number): self
---@field getBounds fun(self: self): number, number, number, number
---@field setVisible fun(self: self, visible: boolean): self
---@field getVisible fun(self: self): boolean
---@field setForeground fun(self: self, color: number): self
---@field getForeground fun(self: self): number
---@field setBackground fun(self: self, color: number|boolean): self
---@field getBackground fun(self: self): number|boolean
---@field setColors fun(self: self, fg: number, bg: number|boolean): self
---@field getColors fun(self: self): number, number|boolean
---@field setDisabled fun(self: self, disabled: boolean): self
---@field getDisabled fun(self: self): boolean
---@field onClick fun(self: self, handler: fun(self: self, button: number, x: number, y: number)): self
---@field onClickUp fun(self: self, handler: fun(self: self, button: number, x: number, y: number)): self
---@field onDrag fun(self: self, handler: fun(self: self, button: number, x: number, y: number)): self
---@field onScroll fun(self: self, handler: fun(self: self, direction: number, x: number, y: number)): self
---@field onKey fun(self: self, handler: fun(self: self, key: number, isHeld: boolean)): self
---@field onKeyUp fun(self: self, handler: fun(self: self, key: number)): self
---@field onChar fun(self: self, handler: fun(self: self, char: string)): self
---@field onPaste fun(self: self, handler: fun(self: self, text: string)): self
---@field onFocus fun(self: self, handler: fun(self: self)): self
---@field onBlur fun(self: self, handler: fun(self: self)): self
---@field onMouseEnter fun(self: self, handler: fun(self: self)): self
---@field onMouseLeave fun(self: self, handler: fun(self: self)): self
---@field focus fun(self: self): self
---@field destroy fun(self: self): self
---@field markDirty fun(self: self): self
---@field apply fun(self: self, props: table): self
---@field fire fun(self: self, event: string, ...: any): boolean

---@class LabelProps : ElementProps
---@field text? string

---@class Label : Element
---@field text string
---@field setText fun(self: Label, text: string): Label
---@field getText fun(self: Label): string

---@class ButtonProps : ElementProps
---@field text? string

---@class Button : Element
---@field text string
---@field setText fun(self: Button, text: string): Button
---@field getText fun(self: Button): string

---@class InputProps : ElementProps
---@field text? string
---@field placeholder? string
---@field inputType? string

---@class Input : Element
---@field text string
---@field placeholder string
---@field inputType string
---@field setText fun(self: Input, text: string): Input
---@field getText fun(self: Input): string
---@field setValue fun(self: Input, val: any): Input
---@field getValue fun(self: Input): any
---@field setPlaceholder fun(self: Input, placeholder: string): Input
---@field getPlaceholder fun(self: Input): string
---@field setInputType fun(self: Input, type: string): Input
---@field onEnter fun(self: Input, handler: fun(self: Input, text: string)): Input
---@field onChange fun(self: Input, handler: fun(self: Input, text: string)): Input

---@class ProgressBarProps : ElementProps
---@field progress? number

---@class ProgressBar : Element
---@field progress number
---@field setProgress fun(self: ProgressBar, progress: number): ProgressBar
---@field getProgress fun(self: ProgressBar): number
---@field setBarColor fun(self: ProgressBar, color: number): ProgressBar
---@field getBarColor fun(self: ProgressBar): number

---@class Container : Element
---@field addChild fun(self: Container, child: Element): Element
---@field removeChild fun(self: Container, child: Element): boolean
---@field getChildren fun(self: Container): Element[]
---@field find fun(self: Container, name: string): Element?
---@field addLabel fun(self: Container, props?: LabelProps|table): Label
---@field addButton fun(self: Container, props?: ButtonProps|table): Button
---@field addInput fun(self: Container, props?: InputProps|table): Input
---@field addFrame fun(self: Container, props?: ElementProps|table): Frame
---@field addDialog fun(self: Container, props?: table): Dialog
---@field addProgressBar fun(self: Container, props?: ProgressBarProps|table): ProgressBar
---@field addCheckbox fun(self: Container, props?: table): any
---@field addSwitch fun(self: Container, props?: table): any
---@field addSlider fun(self: Container, props?: table): any
---@field addList fun(self: Container, props?: table): any
---@field addDropdown fun(self: Container, props?: table): any
---@field addFlex fun(self: Container, props?: table): any
---@field addRow fun(self: Container, props?: table): any
---@field addColumn fun(self: Container, props?: table): any
---@field addTextBox fun(self: Container, props?: table): any
---@field addToast fun(self: Container, props?: table): any

---@class Frame : Container

---@class Dialog : Container
---@field title string
---@field setTitle fun(self: Dialog, title: string): Dialog
---@field getTitle fun(self: Dialog): string
---@field setBoxBackground fun(self: Dialog, color: number): Dialog
---@field getBoxBackground fun(self: Dialog): number
---@field setBoxForeground fun(self: Dialog, color: number): Dialog
---@field getBoxForeground fun(self: Dialog): number
---@field setBoxWidth fun(self: Dialog, width: number): Dialog
---@field getBoxWidth fun(self: Dialog): number
---@field alert fun(self: Dialog, title: string, text: string, callback?: fun()): Dialog
---@field confirm fun(self: Dialog, title: string, text: string, callback?: fun(confirmed: boolean)): Dialog
---@field prompt fun(self: Dialog, title: string, text: string, defaultText?: string, callback?: fun(result: string?)): Dialog
---@field close fun(self: Dialog, result?: any): Dialog
---@field onClose fun(self: Dialog, handler: fun(self: Dialog, result?: any)): Dialog

---@class BaseFrame : Container
---@field setTerm fun(self: BaseFrame, target: any): BaseFrame
---@field setTheme fun(self: BaseFrame, theme: table): BaseFrame
---@field draw fun(self: BaseFrame)
---@field setFocused fun(self: BaseFrame, elem?: Element)
---@field getFocused fun(self: BaseFrame): Element?
---@field isKeyDown fun(self: BaseFrame, key: number): boolean

---@class Basalt
local basalt = {}

basalt.VERSION = "2.5.0-dev"
basalt.traceback = true
basalt.errors = {}

---@param target? any
---@param name? string
---@return BaseFrame
function basalt.createFrame(target, name) end

---@return BaseFrame
function basalt.getMainFrame() end

function basalt.run() end

function basalt.stop() end

---@param event? string
function basalt.update(event, ...) end

---@param fn fun()
---@return thread
function basalt.schedule(fn) end

---@param initial any
---@return BasaltState
function basalt.state(initial) end

---@param initial any
---@return BasaltState
function basalt.signal(initial) end

---@param fn fun(): any
---@return BasaltState
function basalt.computed(fn) end

---@param val any
---@return boolean
function basalt.isState(val) end

---@param r number
---@param g number
---@param b number
---@return number
function basalt.rgb(r, g, b) end

---@return any
function basalt.auto() end

---@param weight? number
---@return any
function basalt.fill(weight) end

---@param pct number
---@return any
function basalt.percent(pct) end

---@param moduleName string
---@return any
function basalt.use(moduleName) end

return basalt
