import UIKit
import AVFoundation
import AVKit

class PavoViewController: UIViewController {

    private let stepIndicatorView = UIView()
    private let stepContainer = UIView()
    private let bottomBar = UIView()
    private let backButton = UIButton()
    private let nextButton = UIButton()
    private let actionButton = UIButton()

    private var stepCircles: [UIView] = []
    private var stepLabels: [UILabel] = []
    private var stepLines: [UIView] = []

    private var currentStep: PavoStep = .requirements {
        didSet { onStepChanged() }
    }
    private var project: PavoProject
    private var projects: [PavoProject]
    private var loadedStep = false

    // Per-step variables
    private var requirementsText = ""
    private var outlineText = ""
    private var charactersText = ""
    private var storyboardText = ""
    private var characterImages: [UIImage] = []
    private var keyframeImages: [UIImage] = []
    private var storyboardVideoURLs: [URL] = []
    private var mergedVideoURL: URL?
    private var isGenerating = false
    private var isMerging = false

    private var apiKey: String {
        UserDefaults.standard.string(forKey: "agnes_api_key") ?? ""
    }
    private let baseURL = "https://apihub.agnes-ai.com/v1"

    init(project: PavoProject? = nil, projects: [PavoProject] = []) {
        self.project = project ?? PavoProject.create()
        self.projects = projects
        if let p = project, p.currentStep > 0, let step = PavoStep(rawValue: p.currentStep) {
            self.currentStep = step
            loadedStep = true
            requirementsText = p.requirements
            outlineText = p.outline
            charactersText = p.characters
            storyboardText = p.storyboard
        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateStepIndicator()
        updateBottomBar()
        buildStepContent()
    }

    override var prefersStatusBarHidden: Bool { true }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    // MARK: - Setup UI

    private func setupUI() {
        let gradientBg = GradientBackgroundView(frame: view.bounds)
        gradientBg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(gradientBg)

        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        let titleLabel = UILabel()
        titleLabel.text = "🎬 Pavo 剧情工厂"
        titleLabel.font = Theme.Font.bold(size: 24)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)

        let closeButton = UIButton()
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = Theme.Font.bold(size: 22)
        closeButton.setTitleColor(Theme.mutedGray, for: .normal)
        closeButton.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        closeButton.layer.cornerRadius = 18
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        headerView.addSubview(closeButton)

        stepIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stepIndicatorView)

        stepContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stepContainer)

        bottomBar.backgroundColor = Theme.cardBackground.withAlphaComponent(0.92)
        bottomBar.layer.cornerRadius = 16
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBar)

        setupStepIndicator()
        setupBottomBar()

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),

            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -12),
            closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36),

            stepIndicatorView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 4),
            stepIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            stepIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            stepIndicatorView.heightAnchor.constraint(equalToConstant: 64),

            stepContainer.topAnchor.constraint(equalTo: stepIndicatorView.bottomAnchor, constant: 8),
            stepContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stepContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stepContainer.bottomAnchor.constraint(equalTo: bottomBar.topAnchor, constant: -8),

            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            bottomBar.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    private func setupStepIndicator() {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stepIndicatorView.addSubview(scrollView)

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: stepIndicatorView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: stepIndicatorView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: stepIndicatorView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: stepIndicatorView.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 4),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -4),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stack.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
        ])

        for step in PavoStep.allCases {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false

            let circle = UIView()
            circle.backgroundColor = Theme.mutedGray.withAlphaComponent(0.3)
            circle.layer.cornerRadius = 16
            circle.layer.borderWidth = 2
            circle.layer.borderColor = Theme.mutedGray.cgColor
            circle.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(circle)

            let label = UILabel()
            label.text = step.title
            label.font = Theme.Font.regular(size: 9)
            label.textColor = Theme.mutedGray
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(label)

            NSLayoutConstraint.activate([
                circle.topAnchor.constraint(equalTo: container.topAnchor),
                circle.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                circle.widthAnchor.constraint(equalToConstant: 32),
                circle.heightAnchor.constraint(equalToConstant: 32),
                label.topAnchor.constraint(equalTo: circle.bottomAnchor, constant: 2),
                label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                label.widthAnchor.constraint(equalToConstant: 44),
                container.widthAnchor.constraint(equalToConstant: 48),
            ])

            stack.addArrangedSubview(container)
            stepCircles.append(circle)
            stepLabels.append(label)
        }

        updateStepIndicator()
    }

    private func updateStepIndicator() {
        for (i, step) in PavoStep.allCases.enumerated() {
            let circle = stepCircles[i]
            let label = stepLabels[i]
            if step.rawValue < currentStep.rawValue {
                circle.backgroundColor = Theme.neonPink.withAlphaComponent(0.3)
                circle.layer.borderColor = Theme.neonPink.cgColor
                label.textColor = Theme.neonPink
            } else if step == currentStep {
                circle.backgroundColor = Theme.electricBlue.withAlphaComponent(0.3)
                circle.layer.borderColor = Theme.electricBlue.cgColor
                label.textColor = Theme.electricBlue
            } else {
                circle.backgroundColor = Theme.mutedGray.withAlphaComponent(0.15)
                circle.layer.borderColor = Theme.mutedGray.cgColor
                label.textColor = Theme.mutedGray
            }
        }
    }

    private func setupBottomBar() {
        backButton.setTitle("◀ 上一步", for: .normal)
        backButton.titleLabel?.font = Theme.Font.bold(size: 14)
        backButton.setTitleColor(Theme.mutedGray, for: .normal)
        backButton.backgroundColor = Theme.cardBackground.withAlphaComponent(0.5)
        backButton.layer.cornerRadius = 16
        backButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(backButton)

        actionButton.titleLabel?.font = Theme.Font.bold(size: 14)
        actionButton.backgroundColor = Theme.electricBlue
        actionButton.layer.cornerRadius = 16
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        actionButton.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(actionButton)

        nextButton.setTitle("下一步 ▶", for: .normal)
        nextButton.titleLabel?.font = Theme.Font.bold(size: 14)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.backgroundColor = Theme.electricBlue
        nextButton.layer.cornerRadius = 16
        nextButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(nextButton)

        NSLayoutConstraint.activate([
            backButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 12),

            actionButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            actionButton.centerXAnchor.constraint(equalTo: bottomBar.centerXAnchor),

            nextButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -12),
        ])

        updateBottomBar()
    }

    private func updateBottomBar() {
        backButton.isHidden = currentStep == .requirements
        nextButton.isHidden = currentStep == .finalVideo

        let showAction: Bool
        let actionTitle: String
        let actionColor: UIColor
        switch currentStep {
        case .requirements:
            showAction = false
            actionTitle = ""
            actionColor = Theme.electricBlue
        case .outline:
            showAction = !outlineText.isEmpty
            actionTitle = "🔄 重新生成"
            actionColor = Theme.mutedGray
        case .characters:
            showAction = !charactersText.isEmpty
            actionTitle = "🔄 重新生成"
            actionColor = Theme.mutedGray
        case .generateImages:
            showAction = !characterImages.isEmpty
            actionTitle = "🔄 重新生成"
            actionColor = Theme.mutedGray
        case .storyboard:
            showAction = !storyboardText.isEmpty
            actionTitle = "🔄 重新生成"
            actionColor = Theme.mutedGray
        case .keyframes:
            showAction = !keyframeImages.isEmpty
            actionTitle = "🔄 重新生成"
            actionColor = Theme.mutedGray
        case .storyboardVideo:
            showAction = !storyboardVideoURLs.isEmpty
            actionTitle = "🔄 重新生成"
            actionColor = Theme.mutedGray
        case .finalVideo:
            showAction = mergedVideoURL != nil && !isMerging
            actionTitle = "💾 保存成片"
            actionColor = Theme.neonPink
        }

        if showAction {
            actionButton.isHidden = false
            actionButton.setTitle(actionTitle, for: .normal)
            actionButton.backgroundColor = actionColor
        } else {
            actionButton.isHidden = true
        }
    }

    // MARK: - Step Content

    private func onStepChanged() {
        updateStepIndicator()
        updateBottomBar()
        buildStepContent()
        saveProject()
    }

    private func buildStepContent() {
        stepContainer.subviews.forEach { $0.removeFromSuperview() }

        switch currentStep {
        case .requirements: buildRequirementsStep()
        case .outline: buildOutlineStep()
        case .characters: buildCharactersStep()
        case .generateImages: buildGenerateImagesStep()
        case .storyboard: buildStoryboardStep()
        case .keyframes: buildKeyframesStep()
        case .storyboardVideo: buildStoryboardVideoStep()
        case .finalVideo: buildFinalVideoStep()
        }
    }

    // MARK: Step 1 - 需求
    private func buildRequirementsStep() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        stepContainer.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: stepContainer.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: stepContainer.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: stepContainer.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: stepContainer.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        let iconLabel = UILabel()
        iconLabel.text = "📋"
        iconLabel.font = .systemFont(ofSize: 48)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconLabel)

        let titleLabel = UILabel()
        titleLabel.text = "输入你的故事灵感"
        titleLabel.font = Theme.Font.bold(size: 22)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        let descLabel = UILabel()
        descLabel.text = "描述你想创作的短剧主题、角色和情节"
        descLabel.font = Theme.Font.regular(size: 14)
        descLabel.textColor = Theme.mutedGray
        descLabel.textAlignment = .center
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descLabel)

        let textView = UITextView()
        textView.font = Theme.Font.regular(size: 16)
        textView.textColor = Theme.brightWhite
        textView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        textView.layer.cornerRadius = 16
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = requirementsText
        textView.delegate = self
        contentView.addSubview(textView)

        let hintLabel = UILabel()
        hintLabel.text = "💡 例如：一个关于未来世界中被遗忘的机器人守护者的故事"
        hintLabel.font = Theme.Font.regular(size: 12)
        hintLabel.textColor = Theme.mutedGray
        hintLabel.numberOfLines = 0
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hintLabel)

        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            textView.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 200),

            hintLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 8),
            hintLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            hintLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            hintLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])
    }

    // MARK: Step 2 - 大纲
    private func buildOutlineStep() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stepContainer.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: stepContainer.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: stepContainer.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: stepContainer.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: stepContainer.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        let iconLabel = UILabel()
        iconLabel.text = "📝"
        iconLabel.font = .systemFont(ofSize: 40)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconLabel)

        let titleLabel = UILabel()
        titleLabel.text = "AI 生成故事大纲"
        titleLabel.font = Theme.Font.bold(size: 20)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        if outlineText.isEmpty && !isGenerating {
            let genButton = UIButton()
            genButton.setTitle("✨ 生成大纲", for: .normal)
            genButton.titleLabel?.font = Theme.Font.bold(size: 18)
            genButton.setTitleColor(.white, for: .normal)
            genButton.backgroundColor = Theme.electricBlue
            genButton.layer.cornerRadius = 20
            genButton.translatesAutoresizingMaskIntoConstraints = false
            genButton.addTarget(self, action: #selector(generateOutline), for: .touchUpInside)
            contentView.addSubview(genButton)

            NSLayoutConstraint.activate([
                iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
                iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
                titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                genButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                genButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
                genButton.widthAnchor.constraint(equalToConstant: 200),
                genButton.heightAnchor.constraint(equalToConstant: 50),
                genButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            ])
            return
        }

        if isGenerating {
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = Theme.electricBlue
            spinner.startAnimating()
            spinner.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(spinner)

            let loadingLabel = UILabel()
            loadingLabel.text = "AI 正在创作大纲..."
            loadingLabel.font = Theme.Font.regular(size: 14)
            loadingLabel.textColor = Theme.mutedGray
            loadingLabel.textAlignment = .center
            loadingLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(loadingLabel)

            NSLayoutConstraint.activate([
                iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
                iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                spinner.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 30),
                spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                loadingLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 12),
                loadingLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                loadingLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -60),
            ])
            return
        }

        let textView = UITextView()
        textView.font = Theme.Font.regular(size: 15)
        textView.textColor = Theme.brightWhite
        textView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.5)
        textView.layer.cornerRadius = 16
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.isEditable = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = outlineText
        textView.delegate = self
        contentView.addSubview(textView)

        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 350),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])
    }

    // MARK: Step 3 - 角色设计
    private func buildCharactersStep() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stepContainer.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: stepContainer.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: stepContainer.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: stepContainer.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: stepContainer.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        let iconLabel = UILabel()
        iconLabel.text = "👥"
        iconLabel.font = .systemFont(ofSize: 40)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconLabel)

        let titleLabel = UILabel()
        titleLabel.text = "AI 设计角色"
        titleLabel.font = Theme.Font.bold(size: 20)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        if charactersText.isEmpty && !isGenerating {
            let genButton = UIButton()
            genButton.setTitle("✨ 设计角色", for: .normal)
            genButton.titleLabel?.font = Theme.Font.bold(size: 18)
            genButton.setTitleColor(.white, for: .normal)
            genButton.backgroundColor = Theme.electricBlue
            genButton.layer.cornerRadius = 20
            genButton.translatesAutoresizingMaskIntoConstraints = false
            genButton.addTarget(self, action: #selector(generateCharacters), for: .touchUpInside)
            contentView.addSubview(genButton)

            NSLayoutConstraint.activate([
                iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
                iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
                titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                genButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                genButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
                genButton.widthAnchor.constraint(equalToConstant: 200),
                genButton.heightAnchor.constraint(equalToConstant: 50),
                genButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            ])
            return
        }

        if isGenerating {
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = Theme.electricBlue
            spinner.startAnimating()
            spinner.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(spinner)
            let loadingLabel = UILabel()
            loadingLabel.text = "AI 正在设计角色..."
            loadingLabel.font = Theme.Font.regular(size: 14)
            loadingLabel.textColor = Theme.mutedGray
            loadingLabel.textAlignment = .center
            loadingLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(loadingLabel)

            NSLayoutConstraint.activate([
                iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
                iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                spinner.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 30),
                spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                loadingLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 12),
                loadingLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                loadingLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -60),
            ])
            return
        }

        let textView = UITextView()
        textView.font = Theme.Font.regular(size: 15)
        textView.textColor = Theme.brightWhite
        textView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.5)
        textView.layer.cornerRadius = 16
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.isEditable = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = charactersText
        textView.delegate = self
        contentView.addSubview(textView)

        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 350),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])
    }

    // MARK: Step 4 - 生图
    private func buildGenerateImagesStep() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stepContainer.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: stepContainer.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: stepContainer.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: stepContainer.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: stepContainer.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        let iconLabel = UILabel()
        iconLabel.text = "🎨"
        iconLabel.font = .systemFont(ofSize: 40)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconLabel)

        let titleLabel = UILabel()
        titleLabel.text = "生成角色形象"
        titleLabel.font = Theme.Font.bold(size: 20)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        if characterImages.isEmpty && !isGenerating {
            let genButton = UIButton()
            genButton.setTitle("🎨 生成角色形象", for: .normal)
            genButton.titleLabel?.font = Theme.Font.bold(size: 18)
            genButton.setTitleColor(.white, for: .normal)
            genButton.backgroundColor = Theme.electricBlue
            genButton.layer.cornerRadius = 20
            genButton.translatesAutoresizingMaskIntoConstraints = false
            genButton.addTarget(self, action: #selector(generateCharacterImages), for: .touchUpInside)
            contentView.addSubview(genButton)

            NSLayoutConstraint.activate([
                iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
                iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
                titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                genButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                genButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
                genButton.widthAnchor.constraint(equalToConstant: 220),
                genButton.heightAnchor.constraint(equalToConstant: 50),
                genButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            ])
            return
        }

        if isGenerating {
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = Theme.electricBlue
            spinner.startAnimating()
            spinner.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(spinner)
            let loadingLabel = UILabel()
            loadingLabel.text = "正在生成角色形象..."
            loadingLabel.font = Theme.Font.regular(size: 14)
            loadingLabel.textColor = Theme.mutedGray
            loadingLabel.textAlignment = .center
            loadingLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(loadingLabel)

            NSLayoutConstraint.activate([
                iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
                iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                spinner.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 30),
                spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                loadingLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 12),
                loadingLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                loadingLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -60),
            ])
            return
        }

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        for (i, image) in characterImages.enumerated() {
            let card = UIView()
            card.backgroundColor = Theme.cardBackground.withAlphaComponent(0.5)
            card.layer.cornerRadius = 16
            card.translatesAutoresizingMaskIntoConstraints = false

            let imgView = UIImageView(image: image)
            imgView.contentMode = .scaleAspectFill
            imgView.layer.cornerRadius = 12
            imgView.clipsToBounds = true
            imgView.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(imgView)

            let charLabel = UILabel()
            charLabel.text = "角色 \(i + 1)"
            charLabel.font = Theme.Font.bold(size: 14)
            charLabel.textColor = Theme.electricBlue
            charLabel.textAlignment = .center
            charLabel.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(charLabel)

            let saveBtn = UIButton()
            saveBtn.setTitle("💾 保存", for: .normal)
            saveBtn.titleLabel?.font = Theme.Font.bold(size: 12)
            saveBtn.backgroundColor = Theme.electricBlue
            saveBtn.layer.cornerRadius = 10
            saveBtn.translatesAutoresizingMaskIntoConstraints = false
            saveBtn.tag = i
            saveBtn.addTarget(self, action: #selector(didTapSaveCharacterImage), for: .touchUpInside)
            card.addSubview(saveBtn)

            NSLayoutConstraint.activate([
                card.widthAnchor.constraint(equalToConstant: 260),
                imgView.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
                imgView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
                imgView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
                imgView.heightAnchor.constraint(equalToConstant: 260),
                charLabel.topAnchor.constraint(equalTo: imgView.bottomAnchor, constant: 8),
                charLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
                saveBtn.topAnchor.constraint(equalTo: charLabel.bottomAnchor, constant: 8),
                saveBtn.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
                saveBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
                saveBtn.heightAnchor.constraint(equalToConstant: 32),
                saveBtn.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            ])

            stackView.addArrangedSubview(card)
        }

        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])
    }

    // MARK: Step 5 - 分镜
    private func buildStoryboardStep() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stepContainer.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: stepContainer.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: stepContainer.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: stepContainer.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: stepContainer.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        let iconLabel = UILabel()
        iconLabel.text = "🎬"
        iconLabel.font = .systemFont(ofSize: 40)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconLabel)

        let titleLabel = UILabel()
        titleLabel.text = "AI 生成分镜脚本"
        titleLabel.font = Theme.Font.bold(size: 20)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        if storyboardText.isEmpty && !isGenerating {
            let genButton = UIButton()
            genButton.setTitle("🎬 生成分镜", for: .normal)
            genButton.titleLabel?.font = Theme.Font.bold(size: 18)
            genButton.setTitleColor(.white, for: .normal)
            genButton.backgroundColor = Theme.electricBlue
            genButton.layer.cornerRadius = 20
            genButton.translatesAutoresizingMaskIntoConstraints = false
            genButton.addTarget(self, action: #selector(generateStoryboard), for: .touchUpInside)
            contentView.addSubview(genButton)

            NSLayoutConstraint.activate([
                iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
                iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
                titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                genButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                genButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
                genButton.widthAnchor.constraint(equalToConstant: 200),
                genButton.heightAnchor.constraint(equalToConstant: 50),
                genButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            ])
            return
        }

        if isGenerating {
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = Theme.electricBlue
            spinner.startAnimating()
            spinner.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(spinner)
            let loadingLabel = UILabel()
            loadingLabel.text = "AI 正在生成分镜..."
            loadingLabel.font = Theme.Font.regular(size: 14)
            loadingLabel.textColor = Theme.mutedGray
            loadingLabel.textAlignment = .center
            loadingLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(loadingLabel)

            NSLayoutConstraint.activate([
                iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
                iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                spinner.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 30),
                spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                loadingLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 12),
                loadingLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                loadingLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -60),
            ])
            return
        }

        let textView = UITextView()
        textView.font = Theme.Font.regular(size: 15)
        textView.textColor = Theme.brightWhite
        textView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.5)
        textView.layer.cornerRadius = 16
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.isEditable = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = storyboardText
        textView.delegate = self
        contentView.addSubview(textView)

        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 350),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])
    }

    // MARK: Step 6 - 关键帧
    private func buildKeyframesStep() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stepContainer.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: stepContainer.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: stepContainer.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: stepContainer.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: stepContainer.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        let iconLabel = UILabel()
        iconLabel.text = "🖼️"
        iconLabel.font = .systemFont(ofSize: 40)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconLabel)

        let titleLabel = UILabel()
        titleLabel.text = "生成关键帧画面"
        titleLabel.font = Theme.Font.bold(size: 20)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        if keyframeImages.isEmpty && !isGenerating {
            let genButton = UIButton()
            genButton.setTitle("🖼️ 生成关键帧", for: .normal)
            genButton.titleLabel?.font = Theme.Font.bold(size: 18)
            genButton.setTitleColor(.white, for: .normal)
            genButton.backgroundColor = Theme.electricBlue
            genButton.layer.cornerRadius = 20
            genButton.translatesAutoresizingMaskIntoConstraints = false
            genButton.addTarget(self, action: #selector(generateKeyframes), for: .touchUpInside)
            contentView.addSubview(genButton)

            NSLayoutConstraint.activate([
                iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
                iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
                titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                genButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                genButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
                genButton.widthAnchor.constraint(equalToConstant: 220),
                genButton.heightAnchor.constraint(equalToConstant: 50),
                genButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            ])
            return
        }

        if isGenerating {
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = Theme.electricBlue
            spinner.startAnimating()
            spinner.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(spinner)
            let loadingLabel = UILabel()
            loadingLabel.text = "正在生成关键帧..."
            loadingLabel.font = Theme.Font.regular(size: 14)
            loadingLabel.textColor = Theme.mutedGray
            loadingLabel.textAlignment = .center
            loadingLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(loadingLabel)

            NSLayoutConstraint.activate([
                iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
                iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                spinner.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 30),
                spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                loadingLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 12),
                loadingLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                loadingLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -60),
            ])
            return
        }

        let imageGrid = UIStackView()
        imageGrid.axis = .vertical
        imageGrid.spacing = 16
        imageGrid.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageGrid)

        for (i, image) in keyframeImages.enumerated() {
            let card = UIView()
            card.backgroundColor = Theme.cardBackground.withAlphaComponent(0.5)
            card.layer.cornerRadius = 16
            card.translatesAutoresizingMaskIntoConstraints = false

            let imgView = UIImageView(image: image)
            imgView.contentMode = .scaleAspectFill
            imgView.layer.cornerRadius = 12
            imgView.clipsToBounds = true
            imgView.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(imgView)

            let frameLabel = UILabel()
            frameLabel.text = "关键帧 \(i + 1)"
            frameLabel.font = Theme.Font.bold(size: 14)
            frameLabel.textColor = Theme.electricBlue
            frameLabel.textAlignment = .center
            frameLabel.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(frameLabel)

            let saveBtn = UIButton()
            saveBtn.setTitle("💾 保存", for: .normal)
            saveBtn.titleLabel?.font = Theme.Font.bold(size: 12)
            saveBtn.backgroundColor = Theme.electricBlue
            saveBtn.layer.cornerRadius = 10
            saveBtn.translatesAutoresizingMaskIntoConstraints = false
            saveBtn.tag = i
            saveBtn.addTarget(self, action: #selector(didTapSaveKeyframe), for: .touchUpInside)
            card.addSubview(saveBtn)

            NSLayoutConstraint.activate([
                card.widthAnchor.constraint(equalToConstant: 260),
                imgView.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
                imgView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
                imgView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
                imgView.heightAnchor.constraint(equalToConstant: 260),
                frameLabel.topAnchor.constraint(equalTo: imgView.bottomAnchor, constant: 8),
                frameLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
                saveBtn.topAnchor.constraint(equalTo: frameLabel.bottomAnchor, constant: 8),
                saveBtn.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
                saveBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
                saveBtn.heightAnchor.constraint(equalToConstant: 32),
                saveBtn.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            ])

            imageGrid.addArrangedSubview(card)
        }

        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageGrid.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            imageGrid.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageGrid.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])
    }

    // MARK: Step 7 - 分镜视频
    private func buildStoryboardVideoStep() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stepContainer.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: stepContainer.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: stepContainer.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: stepContainer.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: stepContainer.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        let iconLabel = UILabel()
        iconLabel.text = "📹"
        iconLabel.font = .systemFont(ofSize: 40)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconLabel)

        let titleLabel = UILabel()
        titleLabel.text = "生成分镜视频片段"
        titleLabel.font = Theme.Font.bold(size: 20)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        if storyboardVideoURLs.isEmpty && !isGenerating {
            let genButton = UIButton()
            genButton.setTitle("📹 生成视频", for: .normal)
            genButton.titleLabel?.font = Theme.Font.bold(size: 18)
            genButton.setTitleColor(.white, for: .normal)
            genButton.backgroundColor = Theme.electricBlue
            genButton.layer.cornerRadius = 20
            genButton.translatesAutoresizingMaskIntoConstraints = false
            genButton.addTarget(self, action: #selector(generateStoryboardVideos), for: .touchUpInside)
            contentView.addSubview(genButton)

            NSLayoutConstraint.activate([
                iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
                iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
                titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                genButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                genButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
                genButton.widthAnchor.constraint(equalToConstant: 200),
                genButton.heightAnchor.constraint(equalToConstant: 50),
                genButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            ])
            return
        }

        if isGenerating {
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = Theme.electricBlue
            spinner.startAnimating()
            spinner.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(spinner)
            let loadingLabel = UILabel()
            loadingLabel.text = "正在生成分镜视频..."
            loadingLabel.font = Theme.Font.regular(size: 14)
            loadingLabel.textColor = Theme.mutedGray
            loadingLabel.textAlignment = .center
            loadingLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(loadingLabel)

            NSLayoutConstraint.activate([
                iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
                iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                spinner.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 30),
                spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                loadingLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 12),
                loadingLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                loadingLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -60),
            ])
            return
        }

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        for (i, videoURL) in storyboardVideoURLs.enumerated() {
            let card = UIView()
            card.backgroundColor = Theme.cardBackground.withAlphaComponent(0.5)
            card.layer.cornerRadius = 16
            card.translatesAutoresizingMaskIntoConstraints = false

            let videoLabel = UILabel()
            videoLabel.text = "视频片段 \(i + 1)"
            videoLabel.font = Theme.Font.bold(size: 14)
            videoLabel.textColor = Theme.neonPink
            videoLabel.textAlignment = .center
            videoLabel.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(videoLabel)

            let saveBtn = UIButton()
            saveBtn.setTitle("💾 保存视频", for: .normal)
            saveBtn.titleLabel?.font = Theme.Font.bold(size: 12)
            saveBtn.backgroundColor = Theme.neonPink
            saveBtn.layer.cornerRadius = 10
            saveBtn.translatesAutoresizingMaskIntoConstraints = false
            saveBtn.tag = i
            saveBtn.addTarget(self, action: #selector(didTapSaveStoryboardVideo), for: .touchUpInside)
            card.addSubview(saveBtn)

            let playBtn = UIButton()
            playBtn.setTitle("▶ 预览", for: .normal)
            playBtn.titleLabel?.font = Theme.Font.bold(size: 14)
            playBtn.setTitleColor(Theme.electricBlue, for: .normal)
            playBtn.backgroundColor = Theme.cardBackground.withAlphaComponent(0.5)
            playBtn.layer.cornerRadius = 10
            playBtn.translatesAutoresizingMaskIntoConstraints = false
            playBtn.tag = i
            playBtn.addTarget(self, action: #selector(didTapPreviewVideo), for: .touchUpInside)
            card.addSubview(playBtn)

            NSLayoutConstraint.activate([
                card.widthAnchor.constraint(equalToConstant: 280),
                videoLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
                videoLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                videoLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
                playBtn.topAnchor.constraint(equalTo: videoLabel.bottomAnchor, constant: 12),
                playBtn.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                playBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
                playBtn.heightAnchor.constraint(equalToConstant: 40),
                saveBtn.topAnchor.constraint(equalTo: playBtn.bottomAnchor, constant: 8),
                saveBtn.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                saveBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
                saveBtn.heightAnchor.constraint(equalToConstant: 36),
                saveBtn.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            ])

            stackView.addArrangedSubview(card)
        }

        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])
    }

    // MARK: Step 8 - 成片
    private func buildFinalVideoStep() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stepContainer.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: stepContainer.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: stepContainer.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: stepContainer.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: stepContainer.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        let iconLabel = UILabel()
        iconLabel.text = "🎞️"
        iconLabel.font = .systemFont(ofSize: 50)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconLabel)

        let titleLabel = UILabel()
        titleLabel.text = "🎉 成片完成！"
        titleLabel.font = Theme.Font.bold(size: 26)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        if isMerging {
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = Theme.neonPink
            spinner.startAnimating()
            spinner.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(spinner)

            let mergeLabel = UILabel()
            mergeLabel.text = "⏳ 正在合成最终成片...\n正在将 \(storyboardVideoURLs.count) 个视频片段合并为完整影片"
            mergeLabel.font = Theme.Font.regular(size: 14)
            mergeLabel.textColor = Theme.mutedGray
            mergeLabel.textAlignment = .center
            mergeLabel.numberOfLines = 0
            mergeLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(mergeLabel)

            NSLayoutConstraint.activate([
                iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
                iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
                titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                spinner.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
                spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                mergeLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 16),
                mergeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
                mergeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
                mergeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -60),
            ])
            return
        }

        let descLabel = UILabel()
        descLabel.text = "\(storyboardVideoURLs.count) 个视频片段已合成为完整短片"
        descLabel.font = Theme.Font.regular(size: 14)
        descLabel.textColor = Theme.mutedGray
        descLabel.textAlignment = .center
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descLabel)

        if let videoURL = mergedVideoURL {
            let playerContainer = UIView()
            playerContainer.backgroundColor = UIColor.black
            playerContainer.layer.cornerRadius = 16
            playerContainer.clipsToBounds = true
            playerContainer.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(playerContainer)

            let player = AVPlayer(url: videoURL)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
            playerLayer.videoGravity = .resizeAspectFill
            playerContainer.layer.addSublayer(playerLayer)

            let playOverlay = UIButton()
            playOverlay.setTitle("▶ 播放", for: .normal)
            playOverlay.titleLabel?.font = Theme.Font.bold(size: 16)
            playOverlay.setTitleColor(.white, for: .normal)
            playOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            playOverlay.layer.cornerRadius = 20
            playOverlay.translatesAutoresizingMaskIntoConstraints = false
            playOverlay.addTarget(self, action: #selector(didTapPlayMergedVideo), for: .touchUpInside)
            playerContainer.addSubview(playOverlay)

            NSLayoutConstraint.activate([
                playerContainer.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 12),
                playerContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                playerContainer.widthAnchor.constraint(equalToConstant: 320),
                playerContainer.heightAnchor.constraint(equalToConstant: 200),

                playOverlay.centerXAnchor.constraint(equalTo: playerContainer.centerXAnchor),
                playOverlay.centerYAnchor.constraint(equalTo: playerContainer.centerYAnchor),
                playOverlay.widthAnchor.constraint(equalToConstant: 100),
                playOverlay.heightAnchor.constraint(equalToConstant: 44),
            ])

            DispatchQueue.main.async {
                playerLayer.frame = playerContainer.bounds
            }
        }

        let summaryCard = UIView()
        summaryCard.backgroundColor = Theme.cardBackground.withAlphaComponent(0.5)
        summaryCard.layer.cornerRadius = 16
        summaryCard.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(summaryCard)

        let summaryStack = UIStackView()
        summaryStack.axis = .vertical
        summaryStack.spacing = 8
        summaryStack.translatesAutoresizingMaskIntoConstraints = false
        summaryCard.addSubview(summaryStack)

        let items = [
            ("📋 需求", !requirementsText.isEmpty),
            ("📝 大纲", !outlineText.isEmpty),
            ("👥 角色", !charactersText.isEmpty && !characterImages.isEmpty),
            ("🎬 分镜", !storyboardText.isEmpty),
            ("🖼️ 关键帧", !keyframeImages.isEmpty),
            ("📹 \(storyboardVideoURLs.count) 个视频片段", true),
            ("🎞️ 合成成片", mergedVideoURL != nil),
        ]

        for (label, done) in items {
            let row = UILabel()
            row.text = "\(done ? "✅" : "⬜") \(label)"
            row.font = Theme.Font.regular(size: 14)
            row.textColor = done ? Theme.neonPink : Theme.mutedGray
            summaryStack.addArrangedSubview(row)
        }

        let successLabel = UILabel()
        successLabel.text = "✨ 你的 AI 短剧已合成为完整影片！"
        successLabel.font = Theme.Font.regular(size: 14)
        successLabel.textColor = Theme.mutedGray
        successLabel.textAlignment = .center
        successLabel.numberOfLines = 0
        successLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(successLabel)

        let saveBtn = UIButton()
        saveBtn.setTitle("💾 保存成片到相册", for: .normal)
        saveBtn.titleLabel?.font = Theme.Font.bold(size: 18)
        saveBtn.setTitleColor(.white, for: .normal)
        saveBtn.backgroundColor = Theme.neonPink
        saveBtn.layer.cornerRadius = 20
        saveBtn.translatesAutoresizingMaskIntoConstraints = false
        saveBtn.addTarget(self, action: #selector(saveMergedVideo), for: .touchUpInside)
        contentView.addSubview(saveBtn)

        let backBtn = UIButton()
        backBtn.setTitle("🏠 返回趣AI", for: .normal)
        backBtn.titleLabel?.font = Theme.Font.bold(size: 16)
        backBtn.setTitleColor(Theme.electricBlue, for: .normal)
        backBtn.backgroundColor = Theme.cardBackground.withAlphaComponent(0.5)
        backBtn.layer.cornerRadius = 20
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        backBtn.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        contentView.addSubview(backBtn)

        var lastAnchor: NSLayoutYAxisAnchor = descLabel.bottomAnchor
        var lastPadding: CGFloat = 12

        if mergedVideoURL != nil {
            lastAnchor = summaryCard.topAnchor
            lastPadding = -16
        }

        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            summaryCard.topAnchor.constraint(equalTo: lastAnchor, constant: lastPadding),
            summaryCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            summaryCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            summaryStack.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: 16),
            summaryStack.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),
            summaryStack.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -16),
            summaryStack.bottomAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: -16),

            successLabel.topAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: 16),
            successLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            successLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),

            saveBtn.topAnchor.constraint(equalTo: successLabel.bottomAnchor, constant: 16),
            saveBtn.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            saveBtn.widthAnchor.constraint(equalToConstant: 260),
            saveBtn.heightAnchor.constraint(equalToConstant: 50),

            backBtn.topAnchor.constraint(equalTo: saveBtn.bottomAnchor, constant: 12),
            backBtn.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backBtn.widthAnchor.constraint(equalToConstant: 200),
            backBtn.heightAnchor.constraint(equalToConstant: 44),
            backBtn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])
    }

    // MARK: - Navigation Actions

    @objc private func didTapClose() {
        saveProject()
        dismiss(animated: true)
    }

    @objc private func didTapBack() {
        guard let prev = PavoStep(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = prev
    }

    @objc private func didTapNext() {
        guard currentStep != .finalVideo else { return }
        if currentStep == .requirements {
            guard !requirementsText.trimmingCharacters(in: .whitespaces).isEmpty else {
                showToast("请先输入故事灵感")
                return
            }
        }
        if currentStep == .storyboardVideo {
            guard !storyboardVideoURLs.isEmpty else {
                showToast("请先生成视频片段")
                return
            }
            startMergingVideos()
            return
        }
        guard let next = PavoStep(rawValue: currentStep.rawValue + 1) else { return }
        currentStep = next
    }

    @objc private func didTapAction() {
        switch currentStep {
        case .outline: generateOutline()
        case .characters: generateCharacters()
        case .generateImages: generateCharacterImages()
        case .storyboard: generateStoryboard()
        case .keyframes: generateKeyframes()
        case .storyboardVideo: generateStoryboardVideos()
        case .finalVideo: saveMergedVideo()
        default: break
        }
    }

    // MARK: - Video Merging

    private func startMergingVideos() {
        guard storyboardVideoURLs.count > 0 else { showToast("没有可合成的视频"); return }
        if storyboardVideoURLs.count == 1 {
            mergedVideoURL = storyboardVideoURLs[0]
            advanceToStep8()
            return
        }
        isMerging = true
        advanceToStep8()
        mergeStoryboardVideos { [weak self] url in
            guard let self = self else { return }
            self.isMerging = false
            if let url = url {
                self.mergedVideoURL = url
                self.buildStepContent()
                self.updateBottomBar()
            } else {
                self.showToast("❌ 视频合成失败，请重试")
            }
        }
    }

    private func advanceToStep8() {
        guard let next = PavoStep(rawValue: PavoStep.storyboardVideo.rawValue + 1) else { return }
        currentStep = next
    }

    private func mergeStoryboardVideos(completion: @escaping (URL?) -> Void) {
        let urls = storyboardVideoURLs
        guard urls.count > 1 else { completion(urls.first); return }

        let composition = AVMutableComposition()
        var currentTime = CMTime.zero

        for url in urls {
            let asset = AVURLAsset(url: url)
            guard let track = asset.tracks(withMediaType: .video).first else { continue }
            let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
            do {
                try composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)?
                    .insertTimeRange(timeRange, of: track, at: currentTime)
                if let audioTrack = asset.tracks(withMediaType: .audio).first,
                   let compAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
                    try compAudioTrack.insertTimeRange(timeRange, of: audioTrack, at: currentTime)
                }
                currentTime = CMTimeAdd(currentTime, asset.duration)
            } catch {
                continue
            }
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("pavo_final_\(UUID().uuidString).mp4")
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil); return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                switch exportSession.status {
                case .completed: completion(outputURL)
                case .cancelled, .failed: completion(nil)
                default: completion(nil)
                }
            }
        }
    }

    // MARK: - API Calls

    private func chatCompletion(prompt: String, systemPrompt: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/chat/completions") else { completion(nil); return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "agnes-chat-v1",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 2048
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: req) { data, _, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let choices = json["choices"] as? [[String: Any]],
                      let first = choices.first,
                      let message = first["message"] as? [String: Any],
                      let content = message["content"] as? String else {
                    if let data = data, let errJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("API Error: \(errJson)")
                    }
                    completion(nil)
                    return
                }
                completion(content)
            }
        }.resume()
    }

    @objc private func generateOutline() {
        guard !apiKey.isEmpty else {
            showToast("请先在 趣我 → 系统设置 中配置 API Key")
            return
        }
        isGenerating = true
        buildStepContent()

        let systemPrompt = "你是一个专业编剧。根据用户的故事需求，生成详细的故事大纲，包括：1. 故事背景 2. 主要角色 3. 情节结构（起承转合）4. 主题思想。请用中文回复，格式清晰。"
        chatCompletion(prompt: requirementsText, systemPrompt: systemPrompt) { [weak self] result in
            guard let self = self else { return }
            self.isGenerating = false
            if let text = result {
                self.outlineText = text
            } else {
                self.showToast("❌ 大纲生成失败，请重试")
            }
            self.buildStepContent()
            self.updateBottomBar()
        }
    }

    @objc private func generateCharacters() {
        guard !apiKey.isEmpty else { showToast("请先配置 API Key"); return }
        isGenerating = true
        buildStepContent()

        let systemPrompt = "你是一个角色设计师。根据故事大纲，设计3-5个角色，每个角色包括：角色名称、年龄性别、性格特点、外貌描述、在故事中的作用。请用中文回复。"
        chatCompletion(prompt: "故事大纲：\n\(outlineText)", systemPrompt: systemPrompt) { [weak self] result in
            guard let self = self else { return }
            self.isGenerating = false
            if let text = result {
                self.charactersText = text
            } else {
                self.showToast("❌ 角色设计失败，请重试")
            }
            self.buildStepContent()
            self.updateBottomBar()
        }
    }

    @objc private func generateCharacterImages() {
        guard !apiKey.isEmpty else { showToast("请先配置 API Key"); return }
        isGenerating = true
        buildStepContent()

        let lines = charactersText.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let charNames = lines.prefix(6).map { $0.trimmingCharacters(in: .whitespaces) }

        let group = DispatchGroup()
        var images: [UIImage] = []
        let semaphore = DispatchSemaphore(value: 3)

        for (i, charDesc) in charNames.enumerated() {
            group.enter()
            DispatchQueue.global().async {
                semaphore.wait()
                self.generateSingleImage(prompt: "角色设计：\(charDesc)，动漫风格，全身照，高清") { image in
                    if let img = image {
                        let _ = PavoProjectManager.saveImage(img, projectId: self.project.id, name: "char_\(i)")
                        images.append(img)
                    }
                    semaphore.signal()
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isGenerating = false
            self.characterImages = images
            self.buildStepContent()
            self.updateBottomBar()
            if images.isEmpty {
                self.showToast("❌ 图片生成失败")
            }
        }
    }

    @objc private func generateStoryboard() {
        guard !apiKey.isEmpty else { showToast("请先配置 API Key"); return }
        isGenerating = true
        buildStepContent()

        let systemPrompt = "你是一个分镜师。根据故事大纲和角色设计，将故事分解为6-8个分镜画面。每个分镜包括：场景编号、场景描述、画面构图、角色动作、镜头类型。请用中文回复，格式清晰。"
        chatCompletion(prompt: "故事大纲：\n\(outlineText)\n\n角色设计：\n\(charactersText)", systemPrompt: systemPrompt) { [weak self] result in
            guard let self = self else { return }
            self.isGenerating = false
            if let text = result {
                self.storyboardText = text
            } else {
                self.showToast("❌ 分镜生成失败，请重试")
            }
            self.buildStepContent()
            self.updateBottomBar()
        }
    }

    @objc private func generateKeyframes() {
        guard !apiKey.isEmpty else { showToast("请先配置 API Key"); return }
        isGenerating = true
        buildStepContent()

        let panels = storyboardText.components(separatedBy: "\n\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let scenes = panels.prefix(6)

        let group = DispatchGroup()
        var images: [UIImage] = []
        let semaphore = DispatchSemaphore(value: 3)

        for (i, scene) in scenes.enumerated() {
            group.enter()
            DispatchQueue.global().async {
                semaphore.wait()
                self.generateSingleImage(prompt: "分镜画面：\(scene.prefix(200))，电影风格，宽屏16:9，高清") { image in
                    if let img = image {
                        let _ = PavoProjectManager.saveImage(img, projectId: self.project.id, name: "keyframe_\(i)")
                        images.append(img)
                    }
                    semaphore.signal()
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isGenerating = false
            self.keyframeImages = images
            self.buildStepContent()
            self.updateBottomBar()
            if images.isEmpty {
                self.showToast("❌ 关键帧生成失败")
            }
        }
    }

    @objc private func generateStoryboardVideos() {
        guard !apiKey.isEmpty else { showToast("请先配置 API Key"); return }
        isGenerating = true
        buildStepContent()

        let imageCount = min(keyframeImages.count, 3)
        guard imageCount > 0 else {
            isGenerating = false
            showToast("请先生成关键帧")
            buildStepContent()
            return
        }

        var videoURLs: [URL] = []
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "video.gen")

        for i in 0..<imageCount {
            group.enter()
            queue.async { [weak self] in
                guard let self = self else { return }
                let semaphore = DispatchSemaphore(value: 0)
                self.generateSingleVideo(prompt: "将画面转换为动态视频，保持构图和色彩") { url in
                    if let url = url {
                        videoURLs.append(url)
                    }
                    semaphore.signal()
                }
                semaphore.wait()
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isGenerating = false
            self.storyboardVideoURLs = videoURLs
            self.buildStepContent()
            self.updateBottomBar()
            if videoURLs.isEmpty {
                self.showToast("❌ 视频生成失败")
            }
        }
    }

    private func generateSingleImage(prompt: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: "\(baseURL)/images/generations") else { completion(nil); return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["model": "agnes-image-2.0-flash", "prompt": prompt, "n": 1]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: req) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let dataArr = json["data"] as? [[String: Any]],
                  let first = dataArr.first,
                  let urlStr = first["url"] as? String,
                  let imgUrl = URL(string: urlStr) else {
                completion(nil)
                return
            }
            URLSession.shared.dataTask(with: imgUrl) { imgData, _, _ in
                if let imgData = imgData, let image = UIImage(data: imgData) {
                    completion(image)
                } else {
                    completion(nil)
                }
            }.resume()
        }.resume()
    }

    private func generateSingleVideo(prompt: String, completion: @escaping (URL?) -> Void) {
        guard let url = URL(string: "\(baseURL)/video/generations") else { completion(nil); return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["model": "agnes-video-v2.0", "prompt": prompt, "n": 1]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: req) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let taskId = json["id"] as? String else {
                completion(nil)
                return
            }
            self.pollSingleVideo(taskId: taskId, completion: completion)
        }.resume()
    }

    private func pollSingleVideo(taskId: String, completion: @escaping (URL?) -> Void) {
        guard let url = URL(string: "\(baseURL)/video/generations/\(taskId)") else { completion(nil); return }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        func poll() {
            URLSession.shared.dataTask(with: req) { data, _, _ in
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) { poll() }
                    return
                }
                let status = json["status"] as? String ?? ""
                if status == "succeeded" || status == "completed" {
                    if let output = json["output"] as? String, let videoUrl = URL(string: output) {
                        URLSession.shared.dataTask(with: videoUrl) { videoData, _, _ in
                            if let videoData = videoData {
                                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mp4")
                                try? videoData.write(to: tempURL)
                                completion(tempURL)
                            } else {
                                completion(nil)
                            }
                        }.resume()
                    } else if let outputArr = json["output"] as? [String], let firstUrl = outputArr.first, let videoUrl = URL(string: firstUrl) {
                        URLSession.shared.dataTask(with: videoUrl) { videoData, _, _ in
                            if let videoData = videoData {
                                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mp4")
                                try? videoData.write(to: tempURL)
                                completion(tempURL)
                            } else {
                                completion(nil)
                            }
                        }.resume()
                    } else {
                        completion(nil)
                    }
                } else if status == "failed" {
                    completion(nil)
                } else {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) { poll() }
                }
            }.resume()
        }
        poll()
    }

    // MARK: - Save Actions

    @objc private func didTapSaveCharacterImage(_ sender: UIButton) {
        let idx = sender.tag
        guard idx < characterImages.count else { return }
        UIImageWriteToSavedPhotosAlbum(characterImages[idx], self, #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func didTapSaveKeyframe(_ sender: UIButton) {
        let idx = sender.tag
        guard idx < keyframeImages.count else { return }
        UIImageWriteToSavedPhotosAlbum(keyframeImages[idx], self, #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func didTapSaveStoryboardVideo(_ sender: UIButton) {
        let idx = sender.tag
        guard idx < storyboardVideoURLs.count else { return }
        let url = storyboardVideoURLs[idx]
        showToast("⏳ 正在下载视频...")
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let data = data, error == nil {
                    let temp = FileManager.default.temporaryDirectory.appendingPathComponent("temp_video.mp4")
                    try? data.write(to: temp)
                    UISaveVideoAtPathToSavedPhotosAlbum(temp.path, self, #selector(self.videoSaved(_:didFinishSavingWithError:contextInfo:)), nil)
                } else {
                    self.showToast("❌ 下载失败")
                }
            }
        }.resume()
    }

    @objc private func didTapPreviewVideo(_ sender: UIButton) {
        let idx = sender.tag
        guard idx < storyboardVideoURLs.count else { return }
        let playerVC = AVPlayerViewController()
        playerVC.player = AVPlayer(url: storyboardVideoURLs[idx])
        present(playerVC, animated: true) {
            playerVC.player?.play()
        }
    }

    @objc private func saveMergedVideo() {
        guard let videoURL = mergedVideoURL else { showToast("没有成片可保存"); return }
        showToast("⏳ 正在保存成片到相册...")
        let temp = FileManager.default.temporaryDirectory.appendingPathComponent("pavo_final_save.mp4")
        try? FileManager.default.removeItem(at: temp)
        try? FileManager.default.copyItem(at: videoURL, to: temp)
        UISaveVideoAtPathToSavedPhotosAlbum(temp.path, self, #selector(videoSavedToAlbum(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func didTapPlayMergedVideo() {
        guard let videoURL = mergedVideoURL else { return }
        let playerVC = AVPlayerViewController()
        playerVC.player = AVPlayer(url: videoURL)
        present(playerVC, animated: true) {
            playerVC.player?.play()
        }
    }

    @objc private func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer) {
        showToast(error == nil ? "✅ 图片已保存到相册" : "❌ 保存失败")
    }

    @objc private func videoSavedToAlbum(_ video: String, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer) {
        showToast(error == nil ? "✅ 成片已保存到相册" : "❌ 保存失败")
    }

    // MARK: - Persistence

    private func saveProject() {
        project.requirements = requirementsText
        project.outline = outlineText
        project.characters = charactersText
        project.storyboard = storyboardText
        project.currentStep = currentStep.rawValue
        project.updatedAt = Date()
        if project.title == "新剧本" && !requirementsText.isEmpty {
            let lines = requirementsText.trimmingCharacters(in: .whitespaces).components(separatedBy: "\n")
            project.title = String(lines.first?.prefix(30) ?? "新剧本")
        }
        PavoProjectManager.save(project)
    }

    private func showToast(_ msg: String) {
        let label = UILabel()
        label.text = msg
        label.font = Theme.Font.regular(size: 14)
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.sizeToFit()
        label.frame.size.width += 32
        label.frame.size.height += 16
        label.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY - 60)
        label.alpha = 0
        view.addSubview(label)
        UIView.animate(withDuration: 0.3, animations: { label.alpha = 1 }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, animations: { label.alpha = 0 }) { _ in label.removeFromSuperview() }
        }
    }
}

extension PavoViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        switch currentStep {
        case .requirements: requirementsText = textView.text
        case .outline: outlineText = textView.text
        case .characters: charactersText = textView.text
        case .storyboard: storyboardText = textView.text
        default: break
        }
    }
}
