# StackViews
Small library for assigning auto layout constraints using declarative Stack View/Flex-Box semantics.

## Motivation
There are many reasons for UI Reach production strength maintainable IOS applications to lean towards code based layouting and use storyboards searingly
But programmatic constraints assignment is not very intuitive.
There are may libraries that are trying to address this issue. Some created better syntax for assigning layout constraints, some completely bypassing autolayout engine and render views using there own engine.

This library consists of one major function: *stackViews(...)* and it is trying to simplify very common scenario of stacking collection of child views in to the parent
It is similar to the IOS UIStackView but it works with any view and includes constraining of children view as a part of the same function call and has some options "borrowed" from the flex-box layout engine

Bottom line - one function call includes all the aspects of constraining children inside the StackView

## Sample application
In addition to the StackViews library workspace includes StackViewExamples reference application.
Reference application uses StackView library to replicate Example View Controller from Apple's [Auto Layout Cookbook](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/LayoutUsingStackViews.html).<br>
In addition Sample Application includes interactive view controller where different parameters of the stackViews function can be changed interactively and changes observed in the real time.

<img src="./images/form_view.png" height="300px"><img src="./images/interactive_view.png" height="300px"><img src="./images/interactive_view_2.png" height="300px">

## Usage Example
Here is an annotated code example that generates this form header ([check out source file for more details](./StackViewsExamples/StackViewsExamples/FormExapmle/FormExampleHeaderViewController.swift)):<br>
<img src="./images/form_header_long.png" height="90px">
```Swift
    let image = UIImageView(image: UIImage(named: "PersonProfile"))
    let firstName = UITextField()
    let middleName = UITextField()
    let lastName = UITextField()

    //Stack Fields vertically
    let fieldsStackView = stackViews(
            orientation: .vertical, // vertical stack of 3 rows
            justify: .fill, // because heights of all 3 rows set explicitly (no nil height row) this will make
                            // fieldsStackView height determined by the sum of rows heights and spaces between them

            align: .fill,  // fill all available space across stack axis (horizontally)
            spacing: 10, //vertical spacing between rows
            views: [
                    applyLabel("First Name", ofWidth: 110, toField: firstName),
                    applyLabel("Middle Name", ofWidth: 110, toField: middleName),
                    applyLabel("Last Name", ofWidth: 110, toField: lastName)
            ],
            heights: [25, 25, 25]) // height of each row
        .container

    //set image view to be a square
    image.widthAnchor.constraint(equalTo: image.heightAnchor, multiplier: 1).isActive = true

    //Stack imageView and fieldsStackView horizontally
    //We do not set any explicit widths or heights because height of the header
    //is determined by the height of the fieldsStackView and vertical insets.
    //Height of the image is determined by the height header. Width of the image is determined by image being square
    //And width of the fieldsStackView view we want to be stretchable to fill all the available horizontal space
    _ = stackViews(
            container: self.view, // use ViewController's view as a stack container
            orientation: .horizontal, //stack image and fieldsStackView horizontally
            justify: .fill, // fill all available space along stack axis (horizontally
            align: .fill, // fill all available space across stack axis (vertically)
            insets: Insets(horizontal: 5, vertical: 5), // set space between container view boundaries and
                                                        // and it's children
            spacing: 10, // space between image and fieldsStackView
            views: [image, fieldsStackView])

```
## API 

Api consists of ***stackViews*** function and few small convenience functions. All public functions are in [StackViews.swift](./StackViews/StackViews/StackViews.swift).
```Swift
public func stackViews(
        container: UIView? = nil,
        orientation: Orientation,
        justify: Justify?,
        align: Alignment?,
        insets: Insets = Insets.zero,
        spacing: CGFloat = 0,
        views: [UIView],
        widths: [CGFloat?]? = nil,
        proportionalWidths: [CGFloat?]? = nil,
        heights: [CGFloat?]? = nil,
        proportionalHeights: [CGFloat?]? = nil,
        individualAlignments: [Alignment?]? = nil,
        activateConstrains: Bool = true) -> StackingResult
```
- **container:** Container view that acts as a stack panel.
If view is not provided a new view will be created and returned as a part of the StackingResult structure
- **orientation:** defines the stacking axes as horizontal or vertical.
- **justify:** describes the stacking option along the stacking axis.
supported options _{ **.fill .start .end .spaceBetween .center** }_
If justify parameter is set to nil no justification will be applied
- **align:** describes the stacking option across the stacking axes for all views.
supported options _{ **.fill .start .center .end** }_
Can be overwritten for specific views by the individualAlignments parameter.
If align set to nil and no individualAlignments provided - no views will be aligned
- **insets:** specify insets applied to the edges of the container view.
(Gap between the container view edges and it's children) Default = 0
- **spacing:** spacing between neighboring views along the stacking axis. Default = 0
- **views:** array of view that should be arranged (stacked) inside the container view
- **widths:** array of width values corresponding to each view in views array. nil value indicates that width constraint will not be set
If width array is provided it's length should be equal to the views array length
- **proportionalWidths:** can be used to specify relative width value for views. If bot absolute width value and relative value provided 
than the firs view with both values specified will be used as a 'key' view and all other proportionalWidths will be set in relation to this view. 
For example if we have 3 views with width: [nil, 50, nil] and proportionalWidths: [1,2,3] then resulting constraint width of the views will be: [25, 50, 75]
- **heights:** array of heights values corresponding to each view in views array. nil value indicates that height constraint will not be set
If heights array is provided it's length should be equal to the views array length
- **proportionalHeights:** can be used to specify relative height value for views. If bot absolute height value and relative value provided 
than the firs view with both values specified will be used as a 'key' view and all other proportionalHeights will be set in relation to this view.
For example if we have 3 views with height: [nil, 50, nil] and proportionalHeights: [1,2,3] then resulting constraint height of the views will be: [25, 50, 75]
- **individualAlignments:** Alignment for individual views.

## License
[MIT](./LICENSE)


   